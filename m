From: kaber@trash.net
Subject: [PATCH 01/12] netfilter: ip_tables: fix compilation when debug is enabled
Date: Thu, 13 May 2010 18:16:14 +0200
Message-ID: <1273767385-18225-2-git-send-email-kaber@trash.net>
References: <1273767385-18225-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58074 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759137Ab0EMQQ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 May 2010 12:16:29 -0400
In-Reply-To: <1273767385-18225-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Engelhardt <jengelh@medozas.de>

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 net/ipv4/netfilter/ip_tables.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 3e6af10..f92818f 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -591,7 +591,7 @@ check_entry(const struct ipt_entry *e, const char *name)
 	const struct ipt_entry_target *t;
 
 	if (!ip_checkentry(&e->ip)) {
-		duprintf("ip check failed %p %s.\n", e, name);
+		duprintf("ip check failed %p %s.\n", e, par->match->name);
 		return -EINVAL;
 	}
 
@@ -618,7 +618,7 @@ check_match(struct ipt_entry_match *m, struct xt_mtchk_param *par)
 	ret = xt_check_match(par, m->u.match_size - sizeof(*m),
 	      ip->proto, ip->invflags & IPT_INV_PROTO);
 	if (ret < 0) {
-		duprintf("check failed for `%s'.\n", par.match->name);
+		duprintf("check failed for `%s'.\n", par->match->name);
 		return ret;
 	}
 	return 0;
-- 
1.7.0.4

