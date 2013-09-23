From: Joe Perches <joe@perches.com>
Subject: [PATCH 10/10] gianfar: Remove extern from function prototypes
Date: Mon, 23 Sep 2013 15:11:37 -0700
Message-ID: <0fb9cd29764ddacf21ab582b7c2020f34a0bf4e6.1379974101.git.joe@perches.com>
References: <5570169a078375fa8662adeb2a7f24c1ae718bfb.1379974101.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5570169a078375fa8662adeb2a7f24c1ae718bfb.1379974101.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are a mix of function prototypes with and without extern
in the kernel sources.  Standardize on not using extern for
function prototypes.

Function prototypes don't need to be written with extern.
extern is assumed by the compiler.  Its use is as unnecessary as
using auto to declare automatic/local variables in a block.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/freescale/gianfar.h | 26 +++++++++++++-------------
 1 file changed, 13 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.h b/drivers/net/ethernet/freescale/gianfar.h
index 04112b9..114c58f 100644
--- a/drivers/net/ethernet/freescale/gianfar.h
+++ b/drivers/net/ethernet/freescale/gianfar.h
@@ -1177,21 +1177,21 @@ static inline void gfar_read_filer(struct gfar_private *priv,
 	*fpr = gfar_read(&regs->rqfpr);
 }
 
-extern void lock_rx_qs(struct gfar_private *priv);
-extern void lock_tx_qs(struct gfar_private *priv);
-extern void unlock_rx_qs(struct gfar_private *priv);
-extern void unlock_tx_qs(struct gfar_private *priv);
-extern irqreturn_t gfar_receive(int irq, void *dev_id);
-extern int startup_gfar(struct net_device *dev);
-extern void stop_gfar(struct net_device *dev);
-extern void gfar_halt(struct net_device *dev);
-extern void gfar_phy_test(struct mii_bus *bus, struct phy_device *phydev,
-		int enable, u32 regnum, u32 read);
-extern void gfar_configure_coalescing_all(struct gfar_private *priv);
+void lock_rx_qs(struct gfar_private *priv);
+void lock_tx_qs(struct gfar_private *priv);
+void unlock_rx_qs(struct gfar_private *priv);
+void unlock_tx_qs(struct gfar_private *priv);
+irqreturn_t gfar_receive(int irq, void *dev_id);
+int startup_gfar(struct net_device *dev);
+void stop_gfar(struct net_device *dev);
+void gfar_halt(struct net_device *dev);
+void gfar_phy_test(struct mii_bus *bus, struct phy_device *phydev, int enable,
+		   u32 regnum, u32 read);
+void gfar_configure_coalescing_all(struct gfar_private *priv);
 void gfar_init_sysfs(struct net_device *dev);
 int gfar_set_features(struct net_device *dev, netdev_features_t features);
-extern void gfar_check_rx_parser_mode(struct gfar_private *priv);
-extern void gfar_vlan_mode(struct net_device *dev, netdev_features_t features);
+void gfar_check_rx_parser_mode(struct gfar_private *priv);
+void gfar_vlan_mode(struct net_device *dev, netdev_features_t features);
 
 extern const struct ethtool_ops gfar_ethtool_ops;
 
-- 
1.8.1.2.459.gbcd45b4.dirty
