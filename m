From: Frans Pop <elendil@planet.nl>
Subject: [PATCH 7/9] net/tulip: remove trailing space in messages
Date: Wed, 24 Mar 2010 18:57:34 +0100
Message-ID: <1269453456-13599-7-git-send-email-elendil@planet.nl>
References: <201003241840.18701.elendil@planet.nl>
Cc: Frans Pop <elendil@planet.nl>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201003241840.18701.elendil@planet.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Frans Pop <elendil@planet.nl>
---
 drivers/net/tulip/de4x5.c     |    4 ++--
 drivers/net/tulip/xircom_cb.c |    6 +++---
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/tulip/de4x5.c b/drivers/net/tulip/de4x5.c
index c4ecb9a..55ade89 100644
--- a/drivers/net/tulip/de4x5.c
+++ b/drivers/net/tulip/de4x5.c
@@ -5077,7 +5077,7 @@ mii_get_phy(struct net_device *dev)
 	    lp->phy[k].spd.value = GENERIC_VALUE;  /* TX & T4, H/F Duplex    */
 	    lp->mii_cnt++;
 	    lp->active++;
-	    printk("%s: Using generic MII device control. If the board doesn't operate, \nplease mail the following dump to the author:\n", dev->name);
+	    printk("%s: Using generic MII device control. If the board doesn't operate,\nplease mail the following dump to the author:\n", dev->name);
 	    j = de4x5_debug;
 	    de4x5_debug |= DEBUG_MII;
 	    de4x5_dbg_mii(dev, k);
@@ -5337,7 +5337,7 @@ de4x5_dbg_open(struct net_device *dev)
 	    }
 	}
 	printk("...0x%8.8x\n", le32_to_cpu(lp->tx_ring[i].buf));
-	printk("Ring size: \nRX: %d\nTX: %d\n",
+	printk("Ring size:\nRX: %d\nTX: %d\n",
 	       (short)lp->rxRingSize,
 	       (short)lp->txRingSize);
     }
diff --git a/drivers/net/tulip/xircom_cb.c b/drivers/net/tulip/xircom_cb.c
index acfeeb9..a439e93 100644
--- a/drivers/net/tulip/xircom_cb.c
+++ b/drivers/net/tulip/xircom_cb.c
@@ -350,9 +350,9 @@ static irqreturn_t xircom_interrupt(int irq, void *dev_instance)
 
 #ifdef DEBUG
 	print_binary(status);
-	printk("tx status 0x%08x 0x%08x \n",
+	printk("tx status 0x%08x 0x%08x\n",
 	       card->tx_buffer[0], card->tx_buffer[4]);
-	printk("rx status 0x%08x 0x%08x \n",
+	printk("rx status 0x%08x 0x%08x\n",
 	       card->rx_buffer[0], card->rx_buffer[4]);
 #endif
 	/* Handle shared irq and hotplug */
@@ -462,7 +462,7 @@ static int xircom_open(struct net_device *dev)
 	struct xircom_private *xp = netdev_priv(dev);
 	int retval;
 	enter("xircom_open");
-	pr_info("xircom cardbus adaptor found, registering as %s, using irq %i \n",
+	pr_info("xircom cardbus adaptor found, registering as %s, using irq %i\n",
 		dev->name, dev->irq);
 	retval = request_irq(dev->irq, xircom_interrupt, IRQF_SHARED, dev->name, dev);
 	if (retval) {
-- 
1.6.6.1
