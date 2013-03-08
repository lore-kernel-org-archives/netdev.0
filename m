From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/15] e1000e: cleanup LONG_LINE checkpatch warnings
Date: Fri,  8 Mar 2013 02:07:07 -0800
Message-ID: <1362737237-13363-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1362737237-13363-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:27095 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756335Ab3CHKHZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Mar 2013 05:07:25 -0500
In-Reply-To: <1362737237-13363-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

WARNING:LONG_LINE: line over 80 characters

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/defines.h | 21 +++++++++++----------
 drivers/net/ethernet/intel/e1000e/e1000.h   |  6 ++++--
 drivers/net/ethernet/intel/e1000e/ethtool.c |  3 ++-
 drivers/net/ethernet/intel/e1000e/netdev.c  |  3 ++-
 drivers/net/ethernet/intel/e1000e/param.c   |  6 ++++--
 5 files changed, 23 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/defines.h b/drivers/net/ethernet/intel/e1000e/defines.h
index fc3a4fe..5af602a 100644
--- a/drivers/net/ethernet/intel/e1000e/defines.h
+++ b/drivers/net/ethernet/intel/e1000e/defines.h
@@ -66,7 +66,7 @@
 #define E1000_CTRL_EXT_LINK_MODE_PCIE_SERDES  0x00C00000
 #define E1000_CTRL_EXT_EIAME          0x01000000
 #define E1000_CTRL_EXT_DRV_LOAD       0x10000000 /* Driver loaded bit for FW */
-#define E1000_CTRL_EXT_IAME           0x08000000 /* Interrupt acknowledge Auto-mask */
+#define E1000_CTRL_EXT_IAME		0x08000000 /* Int ACK Auto-mask */
 #define E1000_CTRL_EXT_PBA_CLR        0x80000000 /* PBA Clear */
 #define E1000_CTRL_EXT_LSECCK         0x00001000
 #define E1000_CTRL_EXT_PHYPDEN        0x00100000
@@ -239,7 +239,7 @@
 #define E1000_STATUS_SPEED_1000 0x00000080      /* Speed 1000Mb/s */
 #define E1000_STATUS_LAN_INIT_DONE 0x00000200   /* Lan Init Completion by NVM */
 #define E1000_STATUS_PHYRA      0x00000400      /* PHY Reset Asserted */
-#define E1000_STATUS_GIO_MASTER_ENABLE 0x00080000 /* Status of Master requests. */
+#define E1000_STATUS_GIO_MASTER_ENABLE	0x00080000	/* Master Req status */
 
 #define HALF_DUPLEX 1
 #define FULL_DUPLEX 2
@@ -400,7 +400,8 @@
 #define E1000_ICR_RXDMT0        0x00000010 /* Rx desc min. threshold (0) */
 #define E1000_ICR_RXT0          0x00000080 /* Rx timer intr (ring 0) */
 #define E1000_ICR_ECCER         0x00400000 /* Uncorrectable ECC Error */
-#define E1000_ICR_INT_ASSERTED  0x80000000 /* If this bit asserted, the driver should claim the interrupt */
+/* If this bit asserted, the driver should claim the interrupt */
+#define E1000_ICR_INT_ASSERTED	0x80000000
 #define E1000_ICR_RXQ0          0x00100000 /* Rx Queue 0 Interrupt */
 #define E1000_ICR_RXQ1          0x00200000 /* Rx Queue 1 Interrupt */
 #define E1000_ICR_TXQ0          0x00400000 /* Tx Queue 0 Interrupt */
@@ -583,13 +584,13 @@
 #define E1000_EECD_SEC1VAL   0x00400000 /* Sector One Valid */
 #define E1000_EECD_SEC1VAL_VALID_MASK (E1000_EECD_AUTO_RD | E1000_EECD_PRES)
 
-#define E1000_NVM_RW_REG_DATA   16   /* Offset to data in NVM read/write registers */
-#define E1000_NVM_RW_REG_DONE   2    /* Offset to READ/WRITE done bit */
-#define E1000_NVM_RW_REG_START  1    /* Start operation */
-#define E1000_NVM_RW_ADDR_SHIFT 2    /* Shift to the address bits */
-#define E1000_NVM_POLL_WRITE    1    /* Flag for polling for write complete */
-#define E1000_NVM_POLL_READ     0    /* Flag for polling for read complete */
-#define E1000_FLASH_UPDATES  2000
+#define E1000_NVM_RW_REG_DATA	16	/* Offset to data in NVM r/w regs */
+#define E1000_NVM_RW_REG_DONE	2	/* Offset to READ/WRITE done bit */
+#define E1000_NVM_RW_REG_START	1	/* Start operation */
+#define E1000_NVM_RW_ADDR_SHIFT	2	/* Shift to the address bits */
+#define E1000_NVM_POLL_WRITE	1	/* Flag for polling write complete */
+#define E1000_NVM_POLL_READ	0	/* Flag for polling read complete */
+#define E1000_FLASH_UPDATES	2000
 
 /* NVM Word Offsets */
 #define NVM_COMPAT                 0x0003
diff --git a/drivers/net/ethernet/intel/e1000e/e1000.h b/drivers/net/ethernet/intel/e1000e/e1000.h
index fcc7581..9b6a568 100644
--- a/drivers/net/ethernet/intel/e1000e/e1000.h
+++ b/drivers/net/ethernet/intel/e1000e/e1000.h
@@ -558,12 +558,14 @@ static inline s32 e1000e_update_nvm_checksum(struct e1000_hw *hw)
 	return hw->nvm.ops.update(hw);
 }
 
-static inline s32 e1000_read_nvm(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
+static inline s32 e1000_read_nvm(struct e1000_hw *hw, u16 offset, u16 words,
+				 u16 *data)
 {
 	return hw->nvm.ops.read(hw, offset, words, data);
 }
 
-static inline s32 e1000_write_nvm(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
+static inline s32 e1000_write_nvm(struct e1000_hw *hw, u16 offset, u16 words,
+				  u16 *data)
 {
 	return hw->nvm.ops.write(hw, offset, words, data);
 }
diff --git a/drivers/net/ethernet/intel/e1000e/ethtool.c b/drivers/net/ethernet/intel/e1000e/ethtool.c
index bbd4b1b..6e9d433 100644
--- a/drivers/net/ethernet/intel/e1000e/ethtool.c
+++ b/drivers/net/ethernet/intel/e1000e/ethtool.c
@@ -549,7 +549,8 @@ static int e1000_set_eeprom(struct net_device *netdev,
 	if (eeprom->len == 0)
 		return -EOPNOTSUPP;
 
-	if (eeprom->magic != (adapter->pdev->vendor | (adapter->pdev->device << 16)))
+	if (eeprom->magic !=
+	    (adapter->pdev->vendor | (adapter->pdev->device << 16)))
 		return -EFAULT;
 
 	if (adapter->flags & FLAG_READ_ONLY_NVM)
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 247f61f..1fa61ca 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -6918,7 +6918,8 @@ static DEFINE_PCI_DEVICE_TABLE(e1000_pci_tbl) = {
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82571EB_COPPER), board_82571 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82571EB_FIBER), board_82571 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82571EB_QUAD_COPPER), board_82571 },
-	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82571EB_QUAD_COPPER_LP), board_82571 },
+	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82571EB_QUAD_COPPER_LP),
+	  board_82571 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82571EB_QUAD_FIBER), board_82571 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82571EB_SERDES), board_82571 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82571EB_SERDES_DUAL), board_82571 },
diff --git a/drivers/net/ethernet/intel/e1000e/param.c b/drivers/net/ethernet/intel/e1000e/param.c
index 98da75d..a011743 100644
--- a/drivers/net/ethernet/intel/e1000e/param.c
+++ b/drivers/net/ethernet/intel/e1000e/param.c
@@ -143,7 +143,8 @@ E1000_PARAM(KumeranLockLoss, "Enable Kumeran lock loss workaround");
  *
  * Default Value: 1 (enabled)
  */
-E1000_PARAM(WriteProtectNVM, "Write-protect NVM [WARNING: disabling this can lead to corrupted NVM]");
+E1000_PARAM(WriteProtectNVM,
+	    "Write-protect NVM [WARNING: disabling this can lead to corrupted NVM]");
 
 /* Enable CRC Stripping
  *
@@ -500,7 +501,8 @@ void e1000e_check_options(struct e1000_adapter *adapter)
 
 		if (adapter->flags & FLAG_IS_ICH) {
 			if (num_WriteProtectNVM > bd) {
-				unsigned int write_protect_nvm = WriteProtectNVM[bd];
+				unsigned int write_protect_nvm =
+				    WriteProtectNVM[bd];
 				e1000_validate_option(&write_protect_nvm, &opt,
 						      adapter);
 				if (write_protect_nvm)
-- 
1.7.11.7
