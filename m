From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2 6/6] ip/link_iptnl: fix indentation
Date: Thu, 13 Dec 2012 14:42:54 +0100
Message-ID: <1355406174-10586-6-git-send-email-nicolas.dichtel@6wind.com>
References: <1355406174-10586-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:40566 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753415Ab2LMNpS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2012 08:45:18 -0500
In-Reply-To: <1355406174-10586-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use tabs instead of space when possible.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 ip/link_iptnl.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/ip/link_iptnl.c b/ip/link_iptnl.c
index 238722d..b00d8d9 100644
--- a/ip/link_iptnl.c
+++ b/ip/link_iptnl.c
@@ -298,10 +298,10 @@ static void iptunnel_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[
 		fprintf(f, "nopmtudisc ");
 
 	if (tb[IFLA_IPTUN_FLAGS]) {
-	       __u16 iflags = rta_getattr_u16(tb[IFLA_IPTUN_FLAGS]);
+		__u16 iflags = rta_getattr_u16(tb[IFLA_IPTUN_FLAGS]);
 
-	      if (iflags & SIT_ISATAP)
-		      fprintf(f, "isatap ");
+		if (iflags & SIT_ISATAP)
+			fprintf(f, "isatap ");
 	}
 
 	if (tb[IFLA_IPTUN_6RD_PREFIXLEN] &&
@@ -314,12 +314,12 @@ static void iptunnel_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[
 
 		printf("6rd-prefix %s/%u ",
 		       inet_ntop(AF_INET6, RTA_DATA(tb[IFLA_IPTUN_6RD_PREFIX]),
-			         s1, sizeof(s1)),
+				 s1, sizeof(s1)),
 		       prefixlen);
 		if (relayprefix) {
 			printf("6rd-relay_prefix %s/%u ",
 			       format_host(AF_INET, 4, &relayprefix, s1,
-				           sizeof(s1)),
+					   sizeof(s1)),
 			       relayprefixlen);
 		}
 	}
-- 
1.8.0.1
