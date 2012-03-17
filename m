From: Joe Perches <joe@perches.com>
Subject: [PATCH 2/2] drivers: net: Remove unnecessary line continuations
Date: Sat, 17 Mar 2012 12:14:03 -0700
Message-ID: <67ad900b6f6451b5b28b004def471c9a41b1ee24.1332011552.git.joe@perches.com>
References: <1d738d4a4dd61978f969ed4a43f2dd3717f51a19.1332011552.git.joe@perches.com>
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, cbe-oss-dev@lists.ozlabs.org
To: Geoff Levand <geoff@infradead.org>,
	Ishizaki Kou <kou.ishizaki@toshiba.co.jp>,
	Jens Osterkamp <jens@de.ibm.com>,
	Samuel Ortiz <samuel@sortiz.org>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1d738d4a4dd61978f969ed4a43f2dd3717f51a19.1332011552.git.joe@perches.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Line continuations are error prone so just remove them.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/can/usb/peak_usb/pcan_usb_pro.c  |    4 ++--
 drivers/net/ethernet/micrel/ks8695net.c      |    4 ++--
 drivers/net/ethernet/toshiba/ps3_gelic_net.c |    3 +--
 drivers/net/ethernet/toshiba/spider_net.c    |    4 ++--
 drivers/net/irda/bfin_sir.c                  |    4 ++--
 drivers/net/phy/et1011c.c                    |    9 +++++----
 6 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/drivers/net/can/usb/peak_usb/pcan_usb_pro.c b/drivers/net/can/usb/peak_usb/pcan_usb_pro.c
index 5234586..68f4e12 100644
--- a/drivers/net/can/usb/peak_usb/pcan_usb_pro.c
+++ b/drivers/net/can/usb/peak_usb/pcan_usb_pro.c
@@ -304,8 +304,8 @@ static int pcan_usb_pro_wait_rsp(struct peak_usb_device *dev,
 					   pr->data_type);
 
 			/* check if channel in response corresponds too */
-			else if ((req_channel != 0xff) && \
-				(pr->bus_act.channel != req_channel))
+			else if ((req_channel != 0xff) &&
+				 (pr->bus_act.channel != req_channel))
 				netdev_err(dev->netdev,
 					"got rsp %xh but on chan%u: ignored\n",
 					req_data_type, pr->bus_act.channel);
diff --git a/drivers/net/ethernet/micrel/ks8695net.c b/drivers/net/ethernet/micrel/ks8695net.c
index dccae1d..012e66d 100644
--- a/drivers/net/ethernet/micrel/ks8695net.c
+++ b/drivers/net/ethernet/micrel/ks8695net.c
@@ -1180,8 +1180,8 @@ ks8695_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	if (unlikely(dma_mapping_error(ksp->dev, dmap))) {
 		/* Failed to DMA map this SKB, give it back for now */
 		spin_unlock_irq(&ksp->txq_lock);
-		dev_dbg(ksp->dev, "%s: Could not map DMA memory for "\
-			"transmission, trying later\n", ndev->name);
+		dev_dbg(ksp->dev, "%s: Could not map DMA memory for transmission, trying later\n",
+			ndev->name);
 		return NETDEV_TX_BUSY;
 	}
 
diff --git a/drivers/net/ethernet/toshiba/ps3_gelic_net.c b/drivers/net/ethernet/toshiba/ps3_gelic_net.c
index 5ee82a7..f707b0b 100644
--- a/drivers/net/ethernet/toshiba/ps3_gelic_net.c
+++ b/drivers/net/ethernet/toshiba/ps3_gelic_net.c
@@ -508,8 +508,7 @@ static void gelic_card_release_tx_chain(struct gelic_card *card, int stop)
 		case GELIC_DESCR_DMA_FORCE_END:
 			if (printk_ratelimit())
 				dev_info(ctodev(card),
-					 "%s: forcing end of tx descriptor " \
-					 "with status %x\n",
+					 "%s: forcing end of tx descriptor with status %x\n",
 					 __func__, status);
 			netdev->stats.tx_dropped++;
 			break;
diff --git a/drivers/net/ethernet/toshiba/spider_net.c b/drivers/net/ethernet/toshiba/spider_net.c
index 6199f6b..9039ddf 100644
--- a/drivers/net/ethernet/toshiba/spider_net.c
+++ b/drivers/net/ethernet/toshiba/spider_net.c
@@ -53,8 +53,8 @@
 
 #include "spider_net.h"
 
-MODULE_AUTHOR("Utz Bacher <utz.bacher@de.ibm.com> and Jens Osterkamp " \
-	      "<Jens.Osterkamp@de.ibm.com>");
+MODULE_AUTHOR("Utz Bacher <utz.bacher@de.ibm.com> and "
+	      "Jens Osterkamp <Jens.Osterkamp@de.ibm.com>");
 MODULE_DESCRIPTION("Spider Southbridge Gigabit Ethernet driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(VERSION);
diff --git a/drivers/net/irda/bfin_sir.c b/drivers/net/irda/bfin_sir.c
index a561ae4..089b7e8 100644
--- a/drivers/net/irda/bfin_sir.c
+++ b/drivers/net/irda/bfin_sir.c
@@ -696,8 +696,8 @@ static int __devinit bfin_sir_probe(struct platform_device *pdev)
 	struct bfin_sir_port *sir_port;
 	int err;
 
-	if (pdev->id >= 0 && pdev->id < ARRAY_SIZE(per) && \
-				per[pdev->id][3] == pdev->id) {
+	if (pdev->id >= 0 && pdev->id < ARRAY_SIZE(per) &&
+	    per[pdev->id][3] == pdev->id) {
 		err = peripheral_request_list(per[pdev->id], DRIVER_NAME);
 		if (err)
 			return err;
diff --git a/drivers/net/phy/et1011c.c b/drivers/net/phy/et1011c.c
index a8eb19e..edbccf7 100644
--- a/drivers/net/phy/et1011c.c
+++ b/drivers/net/phy/et1011c.c
@@ -77,10 +77,11 @@ static int et1011c_read_status(struct phy_device *phydev)
 					ET1011C_GIGABIT_SPEED) {
 			val = phy_read(phydev, ET1011C_CONFIG_REG);
 			val &= ~ET1011C_TX_FIFO_MASK;
-			phy_write(phydev, ET1011C_CONFIG_REG, val\
-					| ET1011C_GMII_INTERFACE\
-					| ET1011C_SYS_CLK_EN\
-					| ET1011C_TX_FIFO_DEPTH_16);
+			phy_write(phydev, ET1011C_CONFIG_REG,
+				  (val |
+				   ET1011C_GMII_INTERFACE |
+				   ET1011C_SYS_CLK_EN |
+				   ET1011C_TX_FIFO_DEPTH_16));
 
 		}
 	}
-- 
1.7.8.111.gad25c.dirty

