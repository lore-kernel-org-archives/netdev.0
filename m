From: kaber@trash.net
Subject: [PATCH 64/84] netfilter: bridge-netfilter: update a comment in br_forward.c about ip_fragment()
Date: Mon, 10 May 2010 22:18:35 +0200
Message-ID: <1273522735-24672-65-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bart De Schuymer <bdschuym@pandora.be>

ip_refrag isn't used anymore in the bridge-netfilter code

Signed-off-by: Bart De Schuymer <bdschuym@pandora.be>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/bridge/br_forward.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index 7ab52d0..15abef7 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -43,7 +43,7 @@ int br_dev_queue_push_xmit(struct sk_buff *skb)
 	if (packet_length(skb) > skb->dev->mtu && !skb_is_gso(skb))
 		kfree_skb(skb);
 	else {
-		/* ip_refrag calls ip_fragment, doesn't copy the MAC header. */
+		/* ip_fragment doesn't copy the MAC header */
 		if (nf_bridge_maybe_copy_header(skb))
 			kfree_skb(skb);
 		else {
-- 
1.7.0.4

