From: pablo@netfilter.org
Subject: [PATCH 03/12] netfilter: nf_conntrack_ipv6: fix comment for packets without data
Date: Fri, 28 Dec 2012 12:52:42 +0100
Message-ID: <1356695571-3305-4-git-send-email-pablo@netfilter.org>
References: <1356695571-3305-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:51005 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753267Ab2L1LxQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Dec 2012 06:53:16 -0500
In-Reply-To: <1356695571-3305-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florent Fourcot <florent.fourcot@enst-bretagne.fr>

Remove ambiguity of double negation.

Signed-off-by: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Acked-by: Rick Jones <rick.jones2@hp.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index 00ee17c..137e245 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -81,8 +81,8 @@ static int ipv6_get_l4proto(const struct sk_buff *skb, unsigned int nhoff,
 	}
 	protoff = ipv6_skip_exthdr(skb, extoff, &nexthdr, &frag_off);
 	/*
-	 * (protoff == skb->len) mean that the packet doesn't have no data
-	 * except of IPv6 & ext headers. but it's tracked anyway. - YK
+	 * (protoff == skb->len) means the packet has not data, just
+	 * IPv6 and possibly extensions headers, but it is tracked anyway
 	 */
 	if (protoff < 0 || (frag_off & htons(~0x7)) != 0) {
 		pr_debug("ip6_conntrack_core: can't find proto in pkt\n");
-- 
1.7.10.4
