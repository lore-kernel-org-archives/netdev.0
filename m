From: laura.vasilescu@rosedu.org
Subject: [PATCH][trivial] drivers/net: Fix checkpatch errors in intel/e1000_82575.c
Date: Thu,  2 May 2013 16:06:38 +0300
Message-ID: <1367499998-7494-1-git-send-email-laura.vasilescu@rosedu.org>
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	greg@kroah.com, carolyn.wyborny@intel.com,
	anjali.singhai@intel.com, jeffrey.t.kirsher@intel.com,
	Laura Mihaela Vasilescu <laura.vasilescu@rosedu.org>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Laura Mihaela Vasilescu <laura.vasilescu@rosedu.org>

Signed-off-by: Laura Mihaela Vasilescu <laura.vasilescu@rosedu.org>
---
 drivers/net/ethernet/intel/igb/e1000_82575.c |   33 ++++++++++++--------------
 1 file changed, 15 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.c b/drivers/net/ethernet/intel/igb/e1000_82575.c
index ff6a17c..3afbab6 100644
--- a/drivers/net/ethernet/intel/igb/e1000_82575.c
+++ b/drivers/net/ethernet/intel/igb/e1000_82575.c
@@ -74,8 +74,8 @@ static s32  igb_validate_nvm_checksum_82580(struct e1000_hw *hw);
 static s32  igb_update_nvm_checksum_82580(struct e1000_hw *hw);
 static s32 igb_validate_nvm_checksum_i350(struct e1000_hw *hw);
 static s32 igb_update_nvm_checksum_i350(struct e1000_hw *hw);
-static const u16 e1000_82580_rxpbs_table[] =
-	{ 36, 72, 144, 1, 2, 4, 8, 16,
+static const u16 e1000_82580_rxpbs_table[] = {
+	  36, 72, 144, 1, 2, 4, 8, 16,
 	  35, 70, 140 };
 #define E1000_82580_RXPBS_TABLE_SIZE \
 	(sizeof(e1000_82580_rxpbs_table)/sizeof(u16))
@@ -404,7 +404,7 @@ static s32 igb_init_mac_params_82575(struct e1000_hw *hw)
 static s32 igb_get_invariants_82575(struct e1000_hw *hw)
 {
 	struct e1000_mac_info *mac = &hw->mac;
-	struct e1000_dev_spec_82575 * dev_spec = &hw->dev_spec._82575;
+	struct e1000_dev_spec_82575 *dev_spec = &hw->dev_spec._82575;
 	s32 ret_val;
 	u32 ctrl_ext = 0;
 
@@ -1002,8 +1002,8 @@ static void igb_release_swfw_sync_82575(struct e1000_hw *hw, u16 mask)
 {
 	u32 swfw_sync;
 
-	while (igb_get_hw_semaphore(hw) != 0);
-	/* Empty */
+	while (igb_get_hw_semaphore(hw) != 0)
+		; /* Empty */
 
 	swfw_sync = rd32(E1000_SW_FW_SYNC);
 	swfw_sync &= ~mask;
@@ -1066,7 +1066,7 @@ static s32 igb_check_for_link_82575(struct e1000_hw *hw)
 
 	if (hw->phy.media_type != e1000_media_type_copper) {
 		ret_val = igb_get_pcs_speed_and_duplex_82575(hw, &speed,
-		                                             &duplex);
+							     &duplex);
 		/* Use this flag to determine if link needs to be checked or
 		 * not.  If  we have link clear the flag so that we do not
 		 * continue to check for link.
@@ -1150,20 +1150,18 @@ static s32 igb_get_pcs_speed_and_duplex_82575(struct e1000_hw *hw, u16 *speed,
 		mac->serdes_has_link = true;
 
 		/* Detect and store PCS speed */
-		if (pcs & E1000_PCS_LSTS_SPEED_1000) {
+		if (pcs & E1000_PCS_LSTS_SPEED_1000)
 			*speed = SPEED_1000;
-		} else if (pcs & E1000_PCS_LSTS_SPEED_100) {
+		else if (pcs & E1000_PCS_LSTS_SPEED_100)
 			*speed = SPEED_100;
-		} else {
+		else
 			*speed = SPEED_10;
-		}
 
 		/* Detect and store PCS duplex */
-		if (pcs & E1000_PCS_LSTS_DUPLEX_FULL) {
+		if (pcs & E1000_PCS_LSTS_DUPLEX_FULL)
 			*duplex = FULL_DUPLEX;
-		} else {
+		else
 			*duplex = HALF_DUPLEX;
-		}
 	}
 
 	return 0;
@@ -1222,9 +1220,8 @@ static s32 igb_reset_hw_82575(struct e1000_hw *hw)
 
 	/* set the completion timeout for interface */
 	ret_val = igb_set_pcie_completion_timeout(hw);
-	if (ret_val) {
+	if (ret_val)
 		hw_dbg("PCI-E Set completion timeout has failed.\n");
-	}
 
 	hw_dbg("Masking off all interrupts\n");
 	wr32(E1000_IMC, 0xffffffff);
@@ -1468,7 +1465,7 @@ static s32 igb_setup_serdes_link_82575(struct e1000_hw *hw)
 		 * link either autoneg or be forced to 1000/Full
 		 */
 		ctrl_reg |= E1000_CTRL_SPD_1000 | E1000_CTRL_FRCSPD |
-		            E1000_CTRL_FD | E1000_CTRL_FRCDPX;
+			    E1000_CTRL_FD | E1000_CTRL_FRCDPX;
 
 		/* set speed of 1000/Full if speed/duplex is forced */
 		reg |= E1000_PCS_LCTL_FSV_1000 | E1000_PCS_LCTL_FDV_FULL;
@@ -1784,14 +1781,14 @@ static s32 igb_set_pcie_completion_timeout(struct e1000_hw *hw)
 	 * 16ms to 55ms
 	 */
 	ret_val = igb_read_pcie_cap_reg(hw, PCIE_DEVICE_CONTROL2,
-	                                &pcie_devctl2);
+					&pcie_devctl2);
 	if (ret_val)
 		goto out;
 
 	pcie_devctl2 |= PCIE_DEVICE_CONTROL2_16ms;
 
 	ret_val = igb_write_pcie_cap_reg(hw, PCIE_DEVICE_CONTROL2,
-	                                 &pcie_devctl2);
+					&pcie_devctl2);
 out:
 	/* disable completion timeout resend */
 	gcr &= ~E1000_GCR_CMPL_TMOUT_RESEND;
-- 
1.7.10.4
