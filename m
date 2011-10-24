From: Richard Weinberger <richard@nod.at>
Subject: [PATCH] [TRIVIAL] netfilter: make physdev_mt more readable
Date: Mon, 24 Oct 2011 14:06:41 +0200
Message-ID: <1319458001-14958-1-git-send-email-richard@nod.at>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	trivial@kernel.org, davem@davemloft.net, kaber@trash.net,
	Richard Weinberger <richard@nod.at>
To: netfilter-devel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Richard Weinberger <richard@nod.at>
---
 net/netfilter/xt_physdev.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/xt_physdev.c b/net/netfilter/xt_physdev.c
index d7ca16b..eabb751 100644
--- a/net/netfilter/xt_physdev.c
+++ b/net/netfilter/xt_physdev.c
@@ -28,12 +28,12 @@ physdev_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	const struct xt_physdev_info *info = par->matchinfo;
 	unsigned long ret;
 	const char *indev, *outdev;
-	const struct nf_bridge_info *nf_bridge;
+	const struct nf_bridge_info *nf_bridge = skb->nf_bridge;
 
 	/* Not a bridged IP packet or no info available yet:
 	 * LOCAL_OUT/mangle and LOCAL_OUT/nat don't know if
 	 * the destination device will be a bridge. */
-	if (!(nf_bridge = skb->nf_bridge)) {
+	if (!nf_bridge) {
 		/* Return MATCH if the invert flags of the used options are on */
 		if ((info->bitmask & XT_PHYSDEV_OP_BRIDGED) &&
 		    !(info->invert & XT_PHYSDEV_OP_BRIDGED))
-- 
1.7.7
