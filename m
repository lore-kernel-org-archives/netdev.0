From: Andy Zhou <azhou@nicira.com>
Subject: [patch net-next v2 1/5] net: add 'const' to __ipv6_select_ident()'s input address parameter
Date: Tue, 10 Mar 2015 12:07:14 -0700
Message-ID: <1426014438-9317-2-git-send-email-azhou@nicira.com>
References: <1426014438-9317-1-git-send-email-azhou@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog138.obsmtp.com ([74.125.149.19]:40228 "HELO
	na3sys009aog138.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752647AbbCJTQj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 15:16:39 -0400
Received: by mail-pd0-f178.google.com with SMTP id nh10so4562218pdb.3
        for <netdev@vger.kernel.org>; Tue, 10 Mar 2015 12:16:39 -0700 (PDT)
In-Reply-To: <1426014438-9317-1-git-send-email-azhou@nicira.com>
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
