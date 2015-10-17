From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 24/35] netfilter: ipv6: pointer cast layout
Date: Sat, 17 Oct 2015 13:32:59 +0200
Message-ID: <1445081590-2924-25-git-send-email-pablo@netfilter.org>
References: <1445081590-2924-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1445081590-2924-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ian Morris <ipm@chirality.org.uk>

Correct whitespace layout of a pointer casting.

No changes detected by objdiff.

Signed-off-by: Ian Morris <ipm@chirality.org.uk>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv6/netfilter/nf_conntrack_reasm.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index cfcc71f..deab0a1 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -59,7 +59,7 @@ struct nf_ct_frag6_skb_cb
 	struct sk_buff		*orig;
 };
 
-#define NFCT_FRAG6_CB(skb)	((struct nf_ct_frag6_skb_cb*)((skb)->cb))
+#define NFCT_FRAG6_CB(skb)	((struct nf_ct_frag6_skb_cb *)((skb)->cb))
 
 static struct inet_frags nf_frags;
 
-- 
2.1.4

