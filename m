From: Andy Zhou <azhou@nicira.com>
Subject: [patch net-next 1/4] net: add 'const' to __ipv6_select_ident()'s input address parameter
Date: Mon,  9 Mar 2015 01:01:35 -0700
Message-ID: <1425888098-21875-2-git-send-email-azhou@nicira.com>
References: <1425888098-21875-1-git-send-email-azhou@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog114.obsmtp.com ([74.125.149.211]:41312 "HELO
	na3sys009aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752683AbbCIIKz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 04:10:55 -0400
Received: by mail-pd0-f174.google.com with SMTP id fl12so62029639pdb.5
        for <netdev@vger.kernel.org>; Mon, 09 Mar 2015 01:10:54 -0700 (PDT)
In-Reply-To: <1425888098-21875-1-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This function does not change those addresses.

Signed-off-by: Andy Zhou <azhou@nicira.com>
---
 net/ipv6/output_core.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/output_core.c b/net/ipv6/output_core.c
index 74581f7..86ff1cf 100644
--- a/net/ipv6/output_core.c
+++ b/net/ipv6/output_core.c
@@ -9,8 +9,8 @@
 #include <net/addrconf.h>
 #include <net/secure_seq.h>
 
-static u32 __ipv6_select_ident(u32 hashrnd, struct in6_addr *dst,
-			       struct in6_addr *src)
+static u32 __ipv6_select_ident(u32 hashrnd, const struct in6_addr *dst,
+			       const struct in6_addr *src)
 {
 	u32 hash, id;
 
-- 
1.9.1
