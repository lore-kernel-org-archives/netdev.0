From: Corcodel Marian <corcodel.marian@gmail.com>
Subject: [PATCH ethtool ] Add new interrupt bit FEmp
Date: Tue,  4 Aug 2015 10:52:46 +0300
Message-ID: <1438674766-2179-1-git-send-email-corcodel.marian@gmail.com>
Cc: Corcodel Marian <corcodel.marian@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:38858 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932162AbbHDHxH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2015 03:53:07 -0400
Received: by wibxm9 with SMTP id xm9so11789843wib.1
        for <netdev@vger.kernel.org>; Tue, 04 Aug 2015 00:53:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

   Add new interrupt bit FEmp (Rx FIFO empty under FIFO full
 Status Interrupt)


Signed-off-by: Corcodel Marian <corcodel.marian@gmail.com>
---
 realtek.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/realtek.c b/realtek.c
index e437466..a9185b2 100644
--- a/realtek.c
+++ b/realtek.c
@@ -229,6 +229,7 @@ print_intr_bits(u16 mask)
 		"      %s%s%s%s%s%s%s%s%s%s%s\n",
 		mask & (1 << 15)	? "SERR " : "",
 		mask & (1 << 14)	? "TimeOut " : "",
+		mask & (1 << 9) 	? "FEmp " : "", 
 		mask & (1 << 8)		? "SWInt " : "",
 		mask & (1 << 7)		? "TxNoBuf " : "",
 		mask & (1 << 6)		? "RxFIFO " : "",
-- 
2.1.4
