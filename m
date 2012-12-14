From: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Subject: [PATCH] Fix comment for packets without data
Date: Fri, 14 Dec 2012 11:53:33 +0100
Message-ID: <1355482413-18629-1-git-send-email-florent.fourcot@enst-bretagne.fr>
References: <50CA23AA.1040501@hp.com>
Cc: pablo@netfilter.org, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Florent Fourcot <florent.fourcot@enst-bretagne.fr>
To: rick.jones2@hp.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <50CA23AA.1040501@hp.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove ambiguity of double negation

Signed-off-by: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
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

