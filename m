From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 20/35] netfilter: ipv6: code indentation
Date: Sat, 17 Oct 2015 13:32:55 +0200
Message-ID: <1445081590-2924-21-git-send-email-pablo@netfilter.org>
References: <1445081590-2924-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48405 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752748AbbJQL0Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Oct 2015 07:26:25 -0400
In-Reply-To: <1445081590-2924-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Morris <ipm@chirality.org.uk>

Use tabs instead of spaces to indent code.

No changes detected by objdiff.

Signed-off-by: Ian Morris <ipm@chirality.org.uk>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv6/netfilter/ip6_tables.c           | 4 ++--
 net/ipv6/netfilter/ip6t_SYNPROXY.c        | 2 +-
 net/ipv6/netfilter/nft_chain_route_ipv6.c | 6 +++---
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 0654312..62190c3 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -443,8 +443,8 @@ ip6t_do_table(struct sk_buff *skb,
 			break;
 	} while (!acpar.hotdrop);
 
- 	xt_write_recseq_end(addend);
- 	local_bh_enable();
+	xt_write_recseq_end(addend);
+	local_bh_enable();
 
 #ifdef DEBUG_ALLOW_ALL
 	return NF_ACCEPT;
diff --git a/net/ipv6/netfilter/ip6t_SYNPROXY.c b/net/ipv6/netfilter/ip6t_SYNPROXY.c
index c235660..5312e9d 100644
--- a/net/ipv6/netfilter/ip6t_SYNPROXY.c
+++ b/net/ipv6/netfilter/ip6t_SYNPROXY.c
@@ -244,7 +244,7 @@ synproxy_send_client_ack(const struct synproxy_net *snet,
 	synproxy_build_options(nth, opts);
 
 	synproxy_send_tcp(snet, skb, nskb, skb->nfct, IP_CT_ESTABLISHED_REPLY,
-	                  niph, nth, tcp_hdr_size);
+			  niph, nth, tcp_hdr_size);
 }
 
 static bool
diff --git a/net/ipv6/netfilter/nft_chain_route_ipv6.c b/net/ipv6/netfilter/nft_chain_route_ipv6.c
index 9df75bd..71d995f 100644
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
2.1.4
