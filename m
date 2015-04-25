From: Ian Morris <ipm@chirality.org.uk>
Subject: [PATCH net-next 1/6] ipv6: netfilter: Tidy up indenting
Date: Sat, 25 Apr 2015 10:26:55 +0100
Message-ID: <1429954020-11763-2-git-send-email-ipm@chirality.org.uk>
References: <1429954020-11763-1-git-send-email-ipm@chirality.org.uk>
Cc: Ian Morris <ipm@chirality.org.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from inet-gw.chirality.org.uk ([88.97.209.22]:36728 "EHLO
	yew.chirality.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758802AbbDYJ1K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Apr 2015 05:27:10 -0400
In-Reply-To: <1429954020-11763-1-git-send-email-ipm@chirality.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch cleanses some indent issues in the ipv6 netfilter code by
converting spaces to tabs etc. No changes to functionality. No changes
according to objdiff.

Signed-off-by: Ian Morris <ipm@chirality.org.uk>
---
 net/ipv6/netfilter/ip6_tables.c           | 12 ++++++------
 net/ipv6/netfilter/nft_chain_route_ipv6.c |  6 +++---
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 1a732a1..c6c9de7 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -439,8 +439,8 @@ ip6t_do_table(struct sk_buff *skb,
 
 	*stackptr = origptr;
 
- 	xt_write_recseq_end(addend);
- 	local_bh_enable();
+	xt_write_recseq_end(addend);
+	local_bh_enable();
 
 #ifdef DEBUG_ALLOW_ALL
 	return NF_ACCEPT;
@@ -557,7 +557,7 @@ mark_source_chains(const struct xt_table_info *newinfo,
 				pos = newpos;
 			}
 		}
-		next:
+next:
 		duprintf("Finished chain %u\n", hook);
 	}
 	return 1;
@@ -803,7 +803,7 @@ static void cleanup_entry(struct ip6t_entry *e, struct net *net)
    newinfo) */
 static int
 translate_table(struct net *net, struct xt_table_info *newinfo, void *entry0,
-                const struct ip6t_replace *repl)
+		const struct ip6t_replace *repl)
 {
 	struct ip6t_entry *iter;
 	unsigned int i;
@@ -1085,7 +1085,7 @@ static int compat_table_info(const struct xt_table_info *info,
 #endif
 
 static int get_info(struct net *net, void __user *user,
-                    const int *len, int compat)
+		    const int *len, int compat)
 {
 	char name[XT_TABLE_MAXNAMELEN];
 	struct xt_table *t;
@@ -1147,7 +1147,7 @@ static int get_info(struct net *net, void __user *user,
 
 static int
 get_entries(struct net *net, struct ip6t_get_entries __user *uptr,
-            const int *len)
+	    const int *len)
 {
 	int ret;
 	struct ip6t_get_entries get;
diff --git a/net/ipv6/netfilter/nft_chain_route_ipv6.c b/net/ipv6/netfilter/nft_chain_route_ipv6.c
index 0dafdaa..2ed4048 100644
--- a/net/ipv6/netfilter/nft_chain_route_ipv6.c
+++ b/net/ipv6/netfilter/nft_chain_route_ipv6.c
@@ -61,11 +61,11 @@ static const struct nf_chain_type nft_chain_route_ipv6 = {
 	.name		= "route",
 	.type		= NFT_CHAIN_T_ROUTE,
 	.family		= NFPROTO_IPV6,
-        .owner		= THIS_MODULE,
+	.owner		= THIS_MODULE,
 	.hook_mask	= (1 << NF_INET_LOCAL_OUT),
 	.hooks		= {
-                [NF_INET_LOCAL_OUT]	= nf_route_table_hook,
-        },
+		[NF_INET_LOCAL_OUT]	= nf_route_table_hook,
+	},
 };
 
 static int __init nft_chain_route_init(void)
-- 
1.9.1
