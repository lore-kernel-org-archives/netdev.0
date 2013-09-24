From: Joe Perches <joe@perches.com>
Subject: [PATCH 03/10] oki-semi: Remove extern from function prototypes
Date: Tue, 24 Sep 2013 14:09:57 -0700
Message-ID: <f4588c4d5ded222ed2afb06bcec88c9b57597b1f.1380056108.git.joe@perches.com>
References: <cover.1380056108.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1380056108.git.joe@perches.com>
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
 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h | 56 ++++++++++++-------------
 1 file changed, 28 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
index 6797b10..2a900307 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
@@ -653,38 +653,38 @@ struct pch_gbe_adapter {
 extern const char pch_driver_version[];
 
 /* pch_gbe_main.c */
-extern int pch_gbe_up(struct pch_gbe_adapter *adapter);
-extern void pch_gbe_down(struct pch_gbe_adapter *adapter);
-extern void pch_gbe_reinit_locked(struct pch_gbe_adapter *adapter);
-extern void pch_gbe_reset(struct pch_gbe_adapter *adapter);
-extern int pch_gbe_setup_tx_resources(struct pch_gbe_adapter *adapter,
-				       struct pch_gbe_tx_ring *txdr);
-extern int pch_gbe_setup_rx_resources(struct pch_gbe_adapter *adapter,
-				       struct pch_gbe_rx_ring *rxdr);
-extern void pch_gbe_free_tx_resources(struct pch_gbe_adapter *adapter,
-				       struct pch_gbe_tx_ring *tx_ring);
-extern void pch_gbe_free_rx_resources(struct pch_gbe_adapter *adapter,
-				       struct pch_gbe_rx_ring *rx_ring);
-extern void pch_gbe_update_stats(struct pch_gbe_adapter *adapter);
-extern u32 pch_ch_control_read(struct pci_dev *pdev);
-extern void pch_ch_control_write(struct pci_dev *pdev, u32 val);
-extern u32 pch_ch_event_read(struct pci_dev *pdev);
-extern void pch_ch_event_write(struct pci_dev *pdev, u32 val);
-extern u32 pch_src_uuid_lo_read(struct pci_dev *pdev);
-extern u32 pch_src_uuid_hi_read(struct pci_dev *pdev);
-extern u64 pch_rx_snap_read(struct pci_dev *pdev);
-extern u64 pch_tx_snap_read(struct pci_dev *pdev);
-extern int pch_set_station_address(u8 *addr, struct pci_dev *pdev);
+int pch_gbe_up(struct pch_gbe_adapter *adapter);
+void pch_gbe_down(struct pch_gbe_adapter *adapter);
+void pch_gbe_reinit_locked(struct pch_gbe_adapter *adapter);
+void pch_gbe_reset(struct pch_gbe_adapter *adapter);
+int pch_gbe_setup_tx_resources(struct pch_gbe_adapter *adapter,
+			       struct pch_gbe_tx_ring *txdr);
+int pch_gbe_setup_rx_resources(struct pch_gbe_adapter *adapter,
+			       struct pch_gbe_rx_ring *rxdr);
+void pch_gbe_free_tx_resources(struct pch_gbe_adapter *adapter,
+			       struct pch_gbe_tx_ring *tx_ring);
+void pch_gbe_free_rx_resources(struct pch_gbe_adapter *adapter,
+			       struct pch_gbe_rx_ring *rx_ring);
+void pch_gbe_update_stats(struct pch_gbe_adapter *adapter);
+u32 pch_ch_control_read(struct pci_dev *pdev);
+void pch_ch_control_write(struct pci_dev *pdev, u32 val);
+u32 pch_ch_event_read(struct pci_dev *pdev);
+void pch_ch_event_write(struct pci_dev *pdev, u32 val);
+u32 pch_src_uuid_lo_read(struct pci_dev *pdev);
+u32 pch_src_uuid_hi_read(struct pci_dev *pdev);
+u64 pch_rx_snap_read(struct pci_dev *pdev);
+u64 pch_tx_snap_read(struct pci_dev *pdev);
+int pch_set_station_address(u8 *addr, struct pci_dev *pdev);
 
 /* pch_gbe_param.c */
-extern void pch_gbe_check_options(struct pch_gbe_adapter *adapter);
+void pch_gbe_check_options(struct pch_gbe_adapter *adapter);
 
 /* pch_gbe_ethtool.c */
-extern void pch_gbe_set_ethtool_ops(struct net_device *netdev);
+void pch_gbe_set_ethtool_ops(struct net_device *netdev);
 
 /* pch_gbe_mac.c */
-extern s32 pch_gbe_mac_force_mac_fc(struct pch_gbe_hw *hw);
-extern s32 pch_gbe_mac_read_mac_addr(struct pch_gbe_hw *hw);
-extern u16 pch_gbe_mac_ctrl_miim(struct pch_gbe_hw *hw,
-				  u32 addr, u32 dir, u32 reg, u16 data);
+s32 pch_gbe_mac_force_mac_fc(struct pch_gbe_hw *hw);
+s32 pch_gbe_mac_read_mac_addr(struct pch_gbe_hw *hw);
+u16 pch_gbe_mac_ctrl_miim(struct pch_gbe_hw *hw, u32 addr, u32 dir, u32 reg,
+			  u16 data);
 #endif /* _PCH_GBE_H_ */
-- 
1.8.1.2.459.gbcd45b4.dirty
