From: Ian Morris <ipm@chirality.org.uk>
Subject: [PATCH nf-next 7/7] netfilter-ipv6: pointer cast layout
Date: Sun, 11 Oct 2015 17:32:20 +0100
Message-ID: <1444581140-6255-8-git-send-email-ipm@chirality.org.uk>
References: <1444581140-6255-1-git-send-email-ipm@chirality.org.uk>
Cc: Ian Morris <ipm@chirality.org.uk>
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from inet-gw.chirality.org.uk ([88.97.209.22]:39508 "EHLO
	cedar.ipmorris.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751587AbbJKQc2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Oct 2015 12:32:28 -0400
In-Reply-To: <1444581140-6255-1-git-send-email-ipm@chirality.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Correct whitespace layout of a pointer casting.

No changes detected by objdiff.

Signed-off-by: Ian Morris <ipm@chirality.org.uk>
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
1.9.1
