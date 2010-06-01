From: Joe Perches <joe@perches.com>
Subject: [PATCH 10/21] drivers/net/gianfar.c: Remove unnecessary kmalloc casts
Date: Mon, 31 May 2010 20:23:12 -0700
Message-ID: <787b5a04a6f7f854b0809c4358671d3d69f70efc.1275360951.git.joe@perches.com>
References: <cover.1275360951.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1275360951.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/gianfar.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 1830f31..ab54821 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -681,8 +681,8 @@ static int gfar_of_init(struct of_device *ofdev, struct net_device **pdev)
 		priv->rx_queue[i] = NULL;
 
 	for (i = 0; i < priv->num_tx_queues; i++) {
-		priv->tx_queue[i] =  (struct gfar_priv_tx_q *)kzalloc(
-				sizeof (struct gfar_priv_tx_q), GFP_KERNEL);
+		priv->tx_queue[i] = kzalloc(sizeof(struct gfar_priv_tx_q),
+					    GFP_KERNEL);
 		if (!priv->tx_queue[i]) {
 			err = -ENOMEM;
 			goto tx_alloc_failed;
@@ -694,8 +694,8 @@ static int gfar_of_init(struct of_device *ofdev, struct net_device **pdev)
 	}
 
 	for (i = 0; i < priv->num_rx_queues; i++) {
-		priv->rx_queue[i] = (struct gfar_priv_rx_q *)kzalloc(
-					sizeof (struct gfar_priv_rx_q), GFP_KERNEL);
+		priv->rx_queue[i] = kzalloc(sizeof(struct gfar_priv_rx_q),
+					    GFP_KERNEL);
 		if (!priv->rx_queue[i]) {
 			err = -ENOMEM;
 			goto rx_alloc_failed;
-- 
1.7.0.3.311.g6a6955
