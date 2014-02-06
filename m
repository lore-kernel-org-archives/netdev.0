From: Michal Kubecek <mkubecek@suse.cz>
Subject: [PATCH iproute2 net-next-for-3.13] iplink_bond: fix arp_all_targets
 parameter name in output
Date: Thu,  6 Feb 2014 12:47:33 +0100 (CET)
Message-ID: <20140206114733.58182E5A97@unicorn.suse.cz>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:39457 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756193AbaBFLre (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Feb 2014 06:47:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Name of arp_all_targets parameter in output of "ip -d link show"
is missing trailing "s".

Fixes: 63d127b0 ("iproute2: finish support for bonding attributes")
Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
---
 ip/iplink_bond.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/iplink_bond.c b/ip/iplink_bond.c
index f0e5ab1..f22151e 100644
--- a/ip/iplink_bond.c
+++ b/ip/iplink_bond.c
@@ -428,7 +428,7 @@ static void bond_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 	if (tb[IFLA_BOND_ARP_ALL_TARGETS]) {
 		const char *arp_all_targets = get_name(arp_all_targets_tbl,
 			rta_getattr_u32(tb[IFLA_BOND_ARP_ALL_TARGETS]));
-		fprintf(f, "arp_all_target %s ", arp_all_targets);
+		fprintf(f, "arp_all_targets %s ", arp_all_targets);
 	}
 
 	if (tb[IFLA_BOND_PRIMARY] &&
-- 
1.8.1.4
