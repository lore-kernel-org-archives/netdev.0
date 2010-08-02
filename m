From: kaber@trash.net
Subject: [PATCH 06/28] netfilter: xt_TPROXY: the length of lines should be within 80
Date: Mon,  2 Aug 2010 21:57:23 +0200
Message-ID: <1280779065-9333-7-git-send-email-kaber@trash.net>
References: <1280779065-9333-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1280779065-9333-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Changli Gao <xiaosuo@gmail.com>

According to the Documentation/CodingStyle, the length of lines should
be within 80.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/xt_TPROXY.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/xt_TPROXY.c b/net/netfilter/xt_TPROXY.c
index e1a0ded..c61294d 100644
--- a/net/netfilter/xt_TPROXY.c
+++ b/net/netfilter/xt_TPROXY.c
@@ -37,8 +37,10 @@ tproxy_tg(struct sk_buff *skb, const struct xt_action_param *par)
 		return NF_DROP;
 
 	sk = nf_tproxy_get_sock_v4(dev_net(skb->dev), iph->protocol,
-				   iph->saddr, tgi->laddr ? tgi->laddr : iph->daddr,
-				   hp->source, tgi->lport ? tgi->lport : hp->dest,
+				   iph->saddr,
+				   tgi->laddr ? tgi->laddr : iph->daddr,
+				   hp->source,
+				   tgi->lport ? tgi->lport : hp->dest,
 				   par->in, true);
 
 	/* NOTE: assign_sock consumes our sk reference */
-- 
1.7.1

