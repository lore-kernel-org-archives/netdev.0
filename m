From: Joe Perches <joe@perches.com>
Subject: [PATCH 07/10] brocade: Remove extern from function prototypes
Date: Mon, 23 Sep 2013 15:11:34 -0700
Message-ID: <068587054a8cd5308d1fdf6a5f9bde1078a50cee.1379974101.git.joe@perches.com>
References: <5570169a078375fa8662adeb2a7f24c1ae718bfb.1379974101.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, Rasesh Mody <rmody@brocade.com>
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
 drivers/net/ethernet/brocade/bna/bnad.h | 43 ++++++++++++++++-----------------
 1 file changed, 21 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad.h b/drivers/net/ethernet/brocade/bna/bnad.h
index aefee77..f7e033f 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.h
+++ b/drivers/net/ethernet/brocade/bna/bnad.h
@@ -372,38 +372,37 @@ extern u32		bnad_rxqs_per_cq;
 /*
  * EXTERN PROTOTYPES
  */
-extern u32 *cna_get_firmware_buf(struct pci_dev *pdev);
+u32 *cna_get_firmware_buf(struct pci_dev *pdev);
 /* Netdev entry point prototypes */
-extern void bnad_set_rx_mode(struct net_device *netdev);
-extern struct net_device_stats *bnad_get_netdev_stats(
-				struct net_device *netdev);
-extern int bnad_mac_addr_set_locked(struct bnad *bnad, u8 *mac_addr);
-extern int bnad_enable_default_bcast(struct bnad *bnad);
-extern void bnad_restore_vlans(struct bnad *bnad, u32 rx_id);
-extern void bnad_set_ethtool_ops(struct net_device *netdev);
-extern void bnad_cb_completion(void *arg, enum bfa_status status);
+void bnad_set_rx_mode(struct net_device *netdev);
+struct net_device_stats *bnad_get_netdev_stats(struct net_device *netdev);
+int bnad_mac_addr_set_locked(struct bnad *bnad, u8 *mac_addr);
+int bnad_enable_default_bcast(struct bnad *bnad);
+void bnad_restore_vlans(struct bnad *bnad, u32 rx_id);
+void bnad_set_ethtool_ops(struct net_device *netdev);
+void bnad_cb_completion(void *arg, enum bfa_status status);
 
 /* Configuration & setup */
-extern void bnad_tx_coalescing_timeo_set(struct bnad *bnad);
-extern void bnad_rx_coalescing_timeo_set(struct bnad *bnad);
+void bnad_tx_coalescing_timeo_set(struct bnad *bnad);
+void bnad_rx_coalescing_timeo_set(struct bnad *bnad);
 
-extern int bnad_setup_rx(struct bnad *bnad, u32 rx_id);
-extern int bnad_setup_tx(struct bnad *bnad, u32 tx_id);
-extern void bnad_destroy_tx(struct bnad *bnad, u32 tx_id);
-extern void bnad_destroy_rx(struct bnad *bnad, u32 rx_id);
+int bnad_setup_rx(struct bnad *bnad, u32 rx_id);
+int bnad_setup_tx(struct bnad *bnad, u32 tx_id);
+void bnad_destroy_tx(struct bnad *bnad, u32 tx_id);
+void bnad_destroy_rx(struct bnad *bnad, u32 rx_id);
 
 /* Timer start/stop protos */
-extern void bnad_dim_timer_start(struct bnad *bnad);
+void bnad_dim_timer_start(struct bnad *bnad);
 
 /* Statistics */
-extern void bnad_netdev_qstats_fill(struct bnad *bnad,
-		struct rtnl_link_stats64 *stats);
-extern void bnad_netdev_hwstats_fill(struct bnad *bnad,
-		struct rtnl_link_stats64 *stats);
+void bnad_netdev_qstats_fill(struct bnad *bnad,
+			     struct rtnl_link_stats64 *stats);
+void bnad_netdev_hwstats_fill(struct bnad *bnad,
+			      struct rtnl_link_stats64 *stats);
 
 /* Debugfs */
-void	bnad_debugfs_init(struct bnad *bnad);
-void	bnad_debugfs_uninit(struct bnad *bnad);
+void bnad_debugfs_init(struct bnad *bnad);
+void bnad_debugfs_uninit(struct bnad *bnad);
 
 /* MACROS */
 /* To set & get the stats counters */
-- 
1.8.1.2.459.gbcd45b4.dirty
