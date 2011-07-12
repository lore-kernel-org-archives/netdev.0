From: Andre Heider <a.heider@gmail.com>
Subject: [PATCH 1/3] ps3_gelic: Fix typos
Date: Tue, 12 Jul 2011 22:13:24 +0200
Message-ID: <1310501606-829-2-git-send-email-a.heider@gmail.com>
References: <1310501606-829-1-git-send-email-a.heider@gmail.com>
Cc: netdev@vger.kernel.org, cbe-oss-dev@lists.ozlabs.org,
	Andre Heider <a.heider@gmail.com>
To: Geoff Levand <geoff@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:45807 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753680Ab1GLUNr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2011 16:13:47 -0400
Received: by mail-bw0-f46.google.com with SMTP id 5so4318012bwd.19
        for <netdev@vger.kernel.org>; Tue, 12 Jul 2011 13:13:46 -0700 (PDT)
In-Reply-To: <1310501606-829-1-git-send-email-a.heider@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Andre Heider <a.heider@gmail.com>
---
 drivers/net/ps3_gelic_net.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ps3_gelic_net.c b/drivers/net/ps3_gelic_net.c
index 35e47c3..9652d10 100644
--- a/drivers/net/ps3_gelic_net.c
+++ b/drivers/net/ps3_gelic_net.c
@@ -876,7 +876,7 @@ int gelic_net_xmit(struct sk_buff *skb, struct net_device *netdev)
 	result = gelic_descr_prepare_tx(card, descr, skb);
 	if (result) {
 		/*
-		 * DMA map failed.  As chanses are that failure
+		 * DMA map failed.  As chances are that failure
 		 * would continue, just release skb and return
 		 */
 		netdev->stats.tx_dropped++;
@@ -1041,7 +1041,7 @@ static int gelic_card_decode_one_descr(struct gelic_card *card)
 		goto refill;
 	}
 	/*
-	 * descriptoers any other than FRAME_END here should
+	 * descriptors any other than FRAME_END here should
 	 * be treated as error.
 	 */
 	if (status != GELIC_DESCR_DMA_FRAME_END) {
@@ -1200,7 +1200,7 @@ void gelic_net_poll_controller(struct net_device *netdev)
 #endif /* CONFIG_NET_POLL_CONTROLLER */
 
 /**
- * gelic_net_open - called upon ifonfig up
+ * gelic_net_open - called upon ifconfig up
  * @netdev: interface device structure
  *
  * returns 0 on success, <0 on failure
-- 
1.7.5.4

