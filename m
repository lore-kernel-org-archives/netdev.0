From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 19/24] ixgbe: Numerous whitespace / formatting cleanups
Date: Thu,  3 Mar 2011 05:03:44 -0800
Message-ID: <1299157429-15878-20-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1299157429-15878-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:34597 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758213Ab1CCNEZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Mar 2011 08:04:25 -0500
In-Reply-To: <1299157429-15878-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This patch contains a number of whitespace and formatting cleanups.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_82598.c  |    7 ++-----
 drivers/net/ixgbe/ixgbe_82599.c  |   19 +++++++++----------
 drivers/net/ixgbe/ixgbe_common.c |    7 ++++---
 3 files changed, 15 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/ixgbe/ixgbe_82598.c
index a5b83b7..8f5e347 100644
--- a/drivers/net/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ixgbe/ixgbe_82598.c
@@ -627,7 +627,6 @@ out:
 	return 0;
 }
 
-
 /**
  *  ixgbe_setup_mac_link_82598 - Set MAC link speed
  *  @hw: pointer to hardware structure
@@ -698,7 +697,6 @@ static s32 ixgbe_setup_copper_link_82598(struct ixgbe_hw *hw,
 	/* Setup the PHY according to input speed */
 	status = hw->phy.ops.setup_link_speed(hw, speed, autoneg,
 	                                      autoneg_wait_to_complete);
-
 	/* Set up MAC */
 	ixgbe_start_mac_link_82598(hw, autoneg_wait_to_complete);
 
@@ -1013,13 +1011,12 @@ static s32 ixgbe_write_analog_reg8_82598(struct ixgbe_hw *hw, u32 reg, u8 val)
 }
 
 /**
- *  ixgbe_read_i2c_eeprom_82598 - Read 8 bit EEPROM word of an SFP+ module
- *  over I2C interface through an intermediate phy.
+ *  ixgbe_read_i2c_eeprom_82598 - Reads 8 bit word over I2C interface.
  *  @hw: pointer to hardware structure
  *  @byte_offset: EEPROM byte offset to read
  *  @eeprom_data: value read
  *
- *  Performs byte read operation to SFP module's EEPROM over I2C interface.
+ *  Performs 8 byte read operation to SFP module's EEPROM over I2C interface.
  **/
 static s32 ixgbe_read_i2c_eeprom_82598(struct ixgbe_hw *hw, u8 byte_offset,
 				       u8 *eeprom_data)
diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index 69d345b..5e2edcd 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -417,14 +417,14 @@ static s32 ixgbe_start_mac_link_82599(struct ixgbe_hw *hw,
 	return status;
 }
 
- /**
-  *  ixgbe_disable_tx_laser_multispeed_fiber - Disable Tx laser
-  *  @hw: pointer to hardware structure
-  *
-  *  The base drivers may require better control over SFP+ module
-  *  PHY states.  This includes selectively shutting down the Tx
-  *  laser on the PHY, effectively halting physical link.
-  **/
+/**
+ *  ixgbe_disable_tx_laser_multispeed_fiber - Disable Tx laser
+ *  @hw: pointer to hardware structure
+ *
+ *  The base drivers may require better control over SFP+ module
+ *  PHY states.  This includes selectively shutting down the Tx
+ *  laser on the PHY, effectively halting physical link.
+ **/
 static void ixgbe_disable_tx_laser_multispeed_fiber(struct ixgbe_hw *hw)
 {
 	u32 esdp_reg = IXGBE_READ_REG(hw, IXGBE_ESDP);
@@ -542,7 +542,6 @@ s32 ixgbe_setup_mac_link_multispeed_fiber(struct ixgbe_hw *hw,
 		 * Section 73.10.2, we may have to wait up to 500ms if KR is
 		 * attempted.  82599 uses the same timing for 10g SFI.
 		 */
-
 		for (i = 0; i < 5; i++) {
 			/* Wait for the link partner to also set speed */
 			msleep(100);
@@ -767,7 +766,6 @@ static s32 ixgbe_setup_mac_link_82599(struct ixgbe_hw *hw,
 	else
 		orig_autoc = autoc;
 
-
 	if (link_mode == IXGBE_AUTOC_LMS_KX4_KX_KR ||
 	    link_mode == IXGBE_AUTOC_LMS_KX4_KX_KR_1G_AN ||
 	    link_mode == IXGBE_AUTOC_LMS_KX4_KX_KR_SGMII) {
@@ -1926,6 +1924,7 @@ static s32 ixgbe_enable_rx_dma_82599(struct ixgbe_hw *hw, u32 regval)
 		if (secrxreg & IXGBE_SECRXSTAT_SECRX_RDY)
 			break;
 		else
+			/* Use interrupt-safe sleep just in case */
 			udelay(10);
 	}
 
diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index a12f7c7..33f568c 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -1188,7 +1188,7 @@ s32 ixgbe_update_eeprom_checksum_generic(struct ixgbe_hw *hw)
 	if (status == 0) {
 		checksum = hw->eeprom.ops.calc_checksum(hw);
 		status = hw->eeprom.ops.write(hw, IXGBE_EEPROM_CHECKSUM,
-		                            checksum);
+					      checksum);
 	} else {
 		hw_dbg(hw, "EEPROM read failed\n");
 	}
@@ -1555,7 +1555,9 @@ s32 ixgbe_fc_enable_generic(struct ixgbe_hw *hw, s32 packetbuf_num)
 	 * 2: Tx flow control is enabled (we can send pause frames but
 	 *    we do not support receiving pause frames).
 	 * 3: Both Rx and Tx flow control (symmetric) are enabled.
+#ifdef CONFIG_DCB
 	 * 4: Priority Flow Control is enabled.
+#endif
 	 * other: Invalid.
 	 */
 	switch (hw->fc.current_mode) {
@@ -2392,7 +2394,6 @@ s32 ixgbe_init_uta_tables_generic(struct ixgbe_hw *hw)
 {
 	int i;
 
-
 	for (i = 0; i < 128; i++)
 		IXGBE_WRITE_REG(hw, IXGBE_UTA(i), 0);
 
@@ -2621,7 +2622,7 @@ s32 ixgbe_clear_vfta_generic(struct ixgbe_hw *hw)
  *  Reads the links register to determine if link is up and the current speed
  **/
 s32 ixgbe_check_mac_link_generic(struct ixgbe_hw *hw, ixgbe_link_speed *speed,
-                               bool *link_up, bool link_up_wait_to_complete)
+				 bool *link_up, bool link_up_wait_to_complete)
 {
 	u32 links_reg, links_orig;
 	u32 i;
-- 
1.7.4

