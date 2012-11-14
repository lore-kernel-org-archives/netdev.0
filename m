From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2 1/3] ip/ip6tunnel: fix help for TCLASS
Date: Wed, 14 Nov 2012 16:29:24 +0100
Message-ID: <1352906966-12932-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:34809 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932736Ab2KNP2i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2012 10:28:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Help is "[tclass TCLASS]", but only TOS was described.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 ip/ip6tunnel.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/ip6tunnel.c b/ip/ip6tunnel.c
index c9720eb..b23377a 100644
--- a/ip/ip6tunnel.c
+++ b/ip/ip6tunnel.c
@@ -60,7 +60,7 @@ static void usage(void)
 		IPV6_DEFAULT_TNL_ENCAP_LIMIT);
 	fprintf(stderr, "       TTL       := 0..255 (default=%d)\n",
 		DEFAULT_TNL_HOP_LIMIT);
-	fprintf(stderr, "       TOS       := { 0x0..0xff | inherit }\n");
+	fprintf(stderr, "       TCLASS    := { 0x0..0xff | inherit }\n");
 	fprintf(stderr, "       FLOWLABEL := { 0x0..0xfffff | inherit }\n");
 	exit(-1);
 }
-- 
1.7.12
