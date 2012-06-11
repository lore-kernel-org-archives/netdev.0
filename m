From: pablo@netfilter.org
Subject: [PATCH 21/25] netfilter: decnet: switch hook PFs to nfproto
Date: Mon, 11 Jun 2012 16:43:57 +0200
Message-ID: <1339425841-24171-22-git-send-email-pablo@netfilter.org>
References: <1339425841-24171-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1339425841-24171-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alban Crequy <alban.crequy@collabora.co.uk>

This patch is a cleanup. Use NFPROTO_* for consistency with other
netfilter code.

Signed-off-by: Alban Crequy <alban.crequy@collabora.co.uk>
Reviewed-by: Javier Martinez Canillas <javier.martinez@collabora.co.uk>
Reviewed-by: Vincent Sanders <vincent.sanders@collabora.co.uk>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/decnet/netfilter/dn_rtmsg.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/decnet/netfilter/dn_rtmsg.c b/net/decnet/netfilter/dn_rtmsg.c
index 44b8909..e6f8862 100644
--- a/net/decnet/netfilter/dn_rtmsg.c
+++ b/net/decnet/netfilter/dn_rtmsg.c
@@ -117,7 +117,7 @@ static inline void dnrmg_receive_user_skb(struct sk_buff *skb)
 
 static struct nf_hook_ops dnrmg_ops __read_mostly = {
 	.hook		= dnrmg_hook,
-	.pf		= PF_DECnet,
+	.pf		= NFPROTO_DECNET,
 	.hooknum	= NF_DN_ROUTE,
 	.priority	= NF_DN_PRI_DNRTMSG,
 };
-- 
1.7.10

