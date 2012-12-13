From: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Subject: [PATCH] Fix comment for packets without data
Date: Thu, 13 Dec 2012 19:27:28 +0100
Message-ID: <1355423248-12448-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Florent Fourcot <florent.fourcot@enst-bretagne.fr>
To: pablo@netfilter.org, yoshfuji@linux-ipv6.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The double negation is probably a typo error

Signed-off-by: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
---
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index 00ee17c..d9efe32 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -81,7 +81,7 @@ static int ipv6_get_l4proto(const struct sk_buff *skb, unsigned int nhoff,
 	}
 	protoff = ipv6_skip_exthdr(skb, extoff, &nexthdr, &frag_off);
 	/*
-	 * (protoff == skb->len) mean that the packet doesn't have no data
+	 * (protoff == skb->len) mean that the packet does not have any data
 	 * except of IPv6 & ext headers. but it's tracked anyway. - YK
 	 */
 	if (protoff < 0 || (frag_off & htons(~0x7)) != 0) {
-- 
1.7.10.4

