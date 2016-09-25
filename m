From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 12/53] netfilter: nf_conntrack: remove unused ctl_table_path member in nf_conntrack_l3proto
Date: Mon, 26 Sep 2016 01:06:22 +0200
Message-ID: <1474844823-2026-13-git-send-email-pablo@netfilter.org>
References: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Liping Zhang <liping.zhang@spreadtrum.com>

After commit adf0516845bc ("netfilter: remove ip_conntrack* sysctl
compat code"), ctl_table_path member in struct nf_conntrack_l3proto{}
is not used anymore, remove it.

Signed-off-by: Liping Zhang <liping.zhang@spreadtrum.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_l3proto.h | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_l3proto.h b/include/net/netfilter/nf_conntrack_l3proto.h
index cdc920b4c4c2..8992e4229da9 100644
--- a/include/net/netfilter/nf_conntrack_l3proto.h
+++ b/include/net/netfilter/nf_conntrack_l3proto.h
@@ -63,10 +63,6 @@ struct nf_conntrack_l3proto {
 
 	size_t nla_size;
 
-#ifdef CONFIG_SYSCTL
-	const char		*ctl_table_path;
-#endif /* CONFIG_SYSCTL */
-
 	/* Init l3proto pernet data */
 	int (*init_net)(struct net *net);
 
-- 
2.1.4

