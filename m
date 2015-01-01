From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Subject: [PATCH] isdn: hisax: hfc4s8s_l1:  Remove some unused functions
Date: Thu,  1 Jan 2015 20:17:22 +0100
Message-ID: <1420139842-3573-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Cc: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:39536 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751531AbbAATOW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jan 2015 14:14:22 -0500
Received: by mail-wg0-f43.google.com with SMTP id k14so5520553wgh.30
        for <netdev@vger.kernel.org>; Thu, 01 Jan 2015 11:14:21 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Removes some functions that are not used anywhere:
Read_hfc32() Write_hfc32() Write_hfc16()

This was partially found by using a static code analysis program called cppcheck.

Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
---
 drivers/isdn/hisax/hfc4s8s_l1.c |   21 ---------------------
 1 file changed, 21 deletions(-)

diff --git a/drivers/isdn/hisax/hfc4s8s_l1.c b/drivers/isdn/hisax/hfc4s8s_l1.c
index fc9f9d0..0e5d673 100644
--- a/drivers/isdn/hisax/hfc4s8s_l1.c
+++ b/drivers/isdn/hisax/hfc4s8s_l1.c
@@ -225,20 +225,6 @@ fWrite_hfc8(hfc4s8s_hw *a, u_char c)
 }
 
 static inline void
-Write_hfc16(hfc4s8s_hw *a, u_char b, u_short c)
-{
-	SetRegAddr(a, b);
-	outw(c, a->iobase);
-}
-
-static inline void
-Write_hfc32(hfc4s8s_hw *a, u_char b, u_long c)
-{
-	SetRegAddr(a, b);
-	outl(c, a->iobase);
-}
-
-static inline void
 fWrite_hfc32(hfc4s8s_hw *a, u_long c)
 {
 	outl(c, a->iobase);
@@ -266,13 +252,6 @@ Read_hfc16(hfc4s8s_hw *a, u_char b)
 }
 
 static inline u_long
-Read_hfc32(hfc4s8s_hw *a, u_char b)
-{
-	SetRegAddr(a, b);
-	return (inl((volatile u_int) a->iobase));
-}
-
-static inline u_long
 fRead_hfc32(hfc4s8s_hw *a)
 {
 	return (inl((volatile u_int) a->iobase));
-- 
1.7.10.4
