From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 25/29] ixgbe: Whitespace,
	copyright update and version number change patch
Date: Thu, 11 Sep 2008 20:04:46 -0700
Message-ID: <20080912030358.6234.78183.stgit@jtkirshe-mobile.jf.intel.com>
References: <20080912025404.6234.83037.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	akpm@linux-foundation.org,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.227]:22815 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756396AbYILDEu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 23:04:50 -0400
Received: by rv-out-0506.google.com with SMTP id k40so615228rvb.1
        for <netdev@vger.kernel.org>; Thu, 11 Sep 2008 20:04:49 -0700 (PDT)
In-Reply-To: <20080912025404.6234.83037.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter P Waskiewicz <peter.p.waskiewicz.jr@intel.com>

This patch cleans up a bit of whitespace issues with the driver, updates
the copyright information, and bumps the version number up.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe.h         |   17 +-
 drivers/net/ixgbe/ixgbe_82598.c   |   58 ++----
 drivers/net/ixgbe/ixgbe_common.c  |   57 +++---
 drivers/net/ixgbe/ixgbe_common.h  |    3 
 drivers/net/ixgbe/ixgbe_ethtool.c |   62 +++---
 drivers/net/ixgbe/ixgbe_main.c    |  360 ++++++++++++++++++-------------------
 drivers/net/ixgbe/ixgbe_phy.c     |    3 
 drivers/net/ixgbe/ixgbe_phy.h     |    3 
 drivers/net/ixgbe/ixgbe_type.h    |    3 
 9 files changed, 266 insertions(+), 300 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index d69215e..63f6789 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2007 Intel Corporation.
+  Copyright(c) 1999 - 2008 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -20,7 +20,6 @@
   the file called "COPYING".
 
   Contact Information:
-  Linux NICS <linux.nics@intel.com>
   e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
   Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
 
@@ -321,15 +320,11 @@ extern int ixgbe_up(struct ixgbe_adapter *adapter);
 extern void ixgbe_down(struct ixgbe_adapter *adapter);
 extern void ixgbe_reinit_locked(struct ixgbe_adapter *adapter);
 extern void ixgbe_reset(struct ixgbe_adapter *adapter);
-extern void ixgbe_update_stats(struct ixgbe_adapter *adapter);
 extern void ixgbe_set_ethtool_ops(struct net_device *netdev);
-extern int ixgbe_setup_rx_resources(struct ixgbe_adapter *adapter,
-				    struct ixgbe_ring *rxdr);
-extern int ixgbe_setup_tx_resources(struct ixgbe_adapter *adapter,
-				    struct ixgbe_ring *txdr);
-extern void ixgbe_free_rx_resources(struct ixgbe_adapter *adapter,
-                                    struct ixgbe_ring *rxdr);
-extern void ixgbe_free_tx_resources(struct ixgbe_adapter *adapter,
-                                    struct ixgbe_ring *txdr);
+extern int ixgbe_setup_rx_resources(struct ixgbe_adapter *, struct ixgbe_ring *);
+extern int ixgbe_setup_tx_resources(struct ixgbe_adapter *, struct ixgbe_ring *);
+extern void ixgbe_free_rx_resources(struct ixgbe_adapter *, struct ixgbe_ring *);
+extern void ixgbe_free_tx_resources(struct ixgbe_adapter *, struct ixgbe_ring *);
+extern void ixgbe_update_stats(struct ixgbe_adapter *adapter);
 
 #endif /* _IXGBE_H_ */
diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/ixgbe/ixgbe_82598.c
index a08a267..7cddcfb 100644
--- a/drivers/net/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ixgbe/ixgbe_82598.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2007 Intel Corporation.
+  Copyright(c) 1999 - 2008 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -20,7 +20,6 @@
   the file called "COPYING".
 
   Contact Information:
-  Linux NICS <linux.nics@intel.com>
   e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
   Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
 
@@ -42,33 +41,11 @@
 static s32 ixgbe_get_copper_link_capabilities_82598(struct ixgbe_hw *hw,
                                              ixgbe_link_speed *speed,
                                              bool *autoneg);
-static enum ixgbe_media_type ixgbe_get_media_type_82598(struct ixgbe_hw *hw);
-static s32 ixgbe_setup_fc_82598(struct ixgbe_hw *hw, s32 packetbuf_num);
-static s32 ixgbe_setup_mac_link_82598(struct ixgbe_hw *hw);
-static s32 ixgbe_check_mac_link_82598(struct ixgbe_hw *hw,
-                               ixgbe_link_speed *speed,
-                               bool *link_up, bool link_up_wait_to_complete);
-static s32 ixgbe_setup_mac_link_speed_82598(struct ixgbe_hw *hw,
-                                            ixgbe_link_speed speed,
-                                            bool autoneg,
-                                            bool autoneg_wait_to_complete);
 static s32 ixgbe_setup_copper_link_82598(struct ixgbe_hw *hw);
 static s32 ixgbe_setup_copper_link_speed_82598(struct ixgbe_hw *hw,
                                                ixgbe_link_speed speed,
                                                bool autoneg,
                                                bool autoneg_wait_to_complete);
-static s32 ixgbe_reset_hw_82598(struct ixgbe_hw *hw);
-static s32 ixgbe_set_vmdq_82598(struct ixgbe_hw *hw, u32 rar, u32 vmdq);
-static s32 ixgbe_clear_vmdq_82598(struct ixgbe_hw *hw, u32 rar, u32 vmdq);
-static s32 ixgbe_set_vfta_82598(struct ixgbe_hw *hw, u32 vlan,
-                         u32 vind, bool vlan_on);
-static s32 ixgbe_clear_vfta_82598(struct ixgbe_hw *hw);
-static s32 ixgbe_blink_led_stop_82598(struct ixgbe_hw *hw, u32 index);
-static s32 ixgbe_blink_led_start_82598(struct ixgbe_hw *hw, u32 index);
-static s32 ixgbe_read_analog_reg8_82598(struct ixgbe_hw *hw, u32 reg, u8 *val);
-static s32 ixgbe_write_analog_reg8_82598(struct ixgbe_hw *hw, u32 reg, u8 val);
-static s32 ixgbe_get_supported_physical_layer_82598(struct ixgbe_hw *hw);
-static s32 ixgbe_get_invariants_82598(struct ixgbe_hw *hw);
 
 /**
  */
@@ -112,8 +89,8 @@ static s32 ixgbe_get_invariants_82598(struct ixgbe_hw *hw)
  *  Determines the link capabilities by reading the AUTOC register.
  **/
 static s32 ixgbe_get_link_capabilities_82598(struct ixgbe_hw *hw,
-                                      ixgbe_link_speed *speed,
-					 bool *autoneg)
+                                             ixgbe_link_speed *speed,
+                                             bool *autoneg)
 {
 	s32 status = 0;
 	s32 autoc_reg;
@@ -180,8 +157,8 @@ s32 ixgbe_get_copper_link_capabilities_82598(struct ixgbe_hw *hw,
 	*autoneg = true;
 
 	status = hw->phy.ops.read_reg(hw, IXGBE_MDIO_PHY_SPEED_ABILITY,
-				    IXGBE_MDIO_PMA_PMD_DEV_TYPE,
-				    &speed_ability);
+	                              IXGBE_MDIO_PMA_PMD_DEV_TYPE,
+	                              &speed_ability);
 
 	if (status == 0) {
 		if (speed_ability & IXGBE_MDIO_PHY_SPEED_10G)
@@ -408,8 +385,9 @@ static s32 ixgbe_setup_mac_link_82598(struct ixgbe_hw *hw)
  *
  *  Reads the links register to determine if link is up and the current speed
  **/
-static s32 ixgbe_check_mac_link_82598(struct ixgbe_hw *hw, ixgbe_link_speed *speed,
-                               bool *link_up, bool link_up_wait_to_complete)
+static s32 ixgbe_check_mac_link_82598(struct ixgbe_hw *hw,
+                                      ixgbe_link_speed *speed, bool *link_up,
+                                      bool link_up_wait_to_complete)
 {
 	u32 links_reg;
 	u32 i;
@@ -452,8 +430,8 @@ static s32 ixgbe_check_mac_link_82598(struct ixgbe_hw *hw, ixgbe_link_speed *spe
  *  Set the link speed in the AUTOC register and restarts link.
  **/
 static s32 ixgbe_setup_mac_link_speed_82598(struct ixgbe_hw *hw,
-					    ixgbe_link_speed speed, bool autoneg,
-					    bool autoneg_wait_to_complete)
+                                            ixgbe_link_speed speed, bool autoneg,
+                                            bool autoneg_wait_to_complete)
 {
 	s32 status = 0;
 
@@ -525,15 +503,15 @@ static s32 ixgbe_setup_copper_link_82598(struct ixgbe_hw *hw)
  *  Sets the link speed in the AUTOC register in the MAC and restarts link.
  **/
 static s32 ixgbe_setup_copper_link_speed_82598(struct ixgbe_hw *hw,
-					       ixgbe_link_speed speed,
-					       bool autoneg,
-					       bool autoneg_wait_to_complete)
+                                               ixgbe_link_speed speed,
+                                               bool autoneg,
+                                               bool autoneg_wait_to_complete)
 {
 	s32 status;
 
 	/* Setup the PHY according to input speed */
-		status = hw->phy.ops.setup_link_speed(hw, speed, autoneg,
-						autoneg_wait_to_complete);
+	status = hw->phy.ops.setup_link_speed(hw, speed, autoneg,
+	                                      autoneg_wait_to_complete);
 
 	/* Set MAC to KX/KX4 autoneg, which defaults to Parallel detection */
 	hw->mac.link_attach_type = (IXGBE_AUTOC_10G_KX4 | IXGBE_AUTOC_1G_KX);
@@ -653,7 +631,7 @@ static s32 ixgbe_reset_hw_82598(struct ixgbe_hw *hw)
 		IXGBE_WRITE_REG(hw, IXGBE_AUTOC, autoc);
 	} else {
 		hw->mac.link_attach_type =
-					 (autoc & IXGBE_AUTOC_LMS_ATTACH_TYPE);
+		                         (autoc & IXGBE_AUTOC_LMS_ATTACH_TYPE);
 		hw->mac.link_mode_select = (autoc & IXGBE_AUTOC_LMS_MASK);
 		hw->mac.link_settings_loaded = true;
 	}
@@ -715,7 +693,7 @@ static s32 ixgbe_clear_vmdq_82598(struct ixgbe_hw *hw, u32 rar, u32 vmdq)
  *  Turn on/off specified VLAN in the VLAN filter table.
  **/
 s32 ixgbe_set_vfta_82598(struct ixgbe_hw *hw, u32 vlan, u32 vind,
-	                                              bool vlan_on)
+                         bool vlan_on)
 {
 	u32 regindex;
 	u32 bitindex;
@@ -770,7 +748,7 @@ static s32 ixgbe_clear_vfta_82598(struct ixgbe_hw *hw)
 	for (vlanbyte = 0; vlanbyte < 4; vlanbyte++)
 		for (offset = 0; offset < hw->mac.vft_size; offset++)
 			IXGBE_WRITE_REG(hw, IXGBE_VFTAVIND(vlanbyte, offset),
-			                                                  0);
+			                0);
 
 	return 0;
 }
diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index a11ff0d..f67c684 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2007 Intel Corporation.
+  Copyright(c) 1999 - 2008 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -20,7 +20,6 @@
   the file called "COPYING".
 
   Contact Information:
-  Linux NICS <linux.nics@intel.com>
   e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
   Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
 
@@ -481,7 +480,7 @@ s32 ixgbe_read_eeprom_generic(struct ixgbe_hw *hw, u16 offset, u16 *data)
 
 	if (status == 0)
 		*data = (IXGBE_READ_REG(hw, IXGBE_EERD) >>
-			IXGBE_EEPROM_READ_REG_DATA);
+		         IXGBE_EEPROM_READ_REG_DATA);
 	else
 		hw_dbg(hw, "Eeprom read timed out\n");
 
@@ -620,7 +619,7 @@ static s32 ixgbe_get_eeprom_semaphore(struct ixgbe_hw *hw)
 		 */
 		if (i >= timeout) {
 			hw_dbg(hw, "Driver can't access the Eeprom - Semaphore "
-				 "not granted.\n");
+			       "not granted.\n");
 			ixgbe_release_eeprom_semaphore(hw);
 			status = IXGBE_ERR_EEPROM;
 		}
@@ -1018,14 +1017,14 @@ s32 ixgbe_set_rar_generic(struct ixgbe_hw *hw, u32 index, u8 *addr, u32 vmdq,
 
 	/* Make sure we are using a valid rar index range */
 	if (index < rar_entries) {
-	/*
+		/*
 		 * HW expects these in little endian so we reverse the byte
 		 * order from network order (big endian) to little endian
-	 */
-	rar_low = ((u32)addr[0] |
-		   ((u32)addr[1] << 8) |
-		   ((u32)addr[2] << 16) |
-		   ((u32)addr[3] << 24));
+		 */
+		rar_low = ((u32)addr[0] |
+		           ((u32)addr[1] << 8) |
+		           ((u32)addr[2] << 16) |
+		           ((u32)addr[3] << 24));
 		/*
 		 * Some parts put the VMDq setting in the extra RAH bits,
 		 * so save everything except the lower 16 bits that hold part
@@ -1035,11 +1034,11 @@ s32 ixgbe_set_rar_generic(struct ixgbe_hw *hw, u32 index, u8 *addr, u32 vmdq,
 		rar_high &= ~(0x0000FFFF | IXGBE_RAH_AV);
 		rar_high |= ((u32)addr[4] | ((u32)addr[5] << 8));
 
-	if (enable_addr != 0)
-		rar_high |= IXGBE_RAH_AV;
+		if (enable_addr != 0)
+			rar_high |= IXGBE_RAH_AV;
 
-	IXGBE_WRITE_REG(hw, IXGBE_RAL(index), rar_low);
-	IXGBE_WRITE_REG(hw, IXGBE_RAH(index), rar_high);
+		IXGBE_WRITE_REG(hw, IXGBE_RAL(index), rar_low);
+		IXGBE_WRITE_REG(hw, IXGBE_RAH(index), rar_high);
 	} else {
 		hw_dbg(hw, "RAR index %d is out of range.\n", index);
 	}
@@ -1137,18 +1136,18 @@ s32 ixgbe_init_rx_addrs_generic(struct ixgbe_hw *hw)
 		hw->mac.ops.get_mac_addr(hw, hw->mac.addr);
 
 		hw_dbg(hw, " Keeping Current RAR0 Addr =%.2X %.2X %.2X ",
-			  hw->mac.addr[0], hw->mac.addr[1],
-			  hw->mac.addr[2]);
+		       hw->mac.addr[0], hw->mac.addr[1],
+		       hw->mac.addr[2]);
 		hw_dbg(hw, "%.2X %.2X %.2X\n", hw->mac.addr[3],
-			  hw->mac.addr[4], hw->mac.addr[5]);
+		       hw->mac.addr[4], hw->mac.addr[5]);
 	} else {
 		/* Setup the receive address. */
 		hw_dbg(hw, "Overriding MAC Address in RAR[0]\n");
 		hw_dbg(hw, " New MAC Addr =%.2X %.2X %.2X ",
-			  hw->mac.addr[0], hw->mac.addr[1],
-			  hw->mac.addr[2]);
+		       hw->mac.addr[0], hw->mac.addr[1],
+		       hw->mac.addr[2]);
 		hw_dbg(hw, "%.2X %.2X %.2X\n", hw->mac.addr[3],
-			  hw->mac.addr[4], hw->mac.addr[5]);
+		       hw->mac.addr[4], hw->mac.addr[5]);
 
 		hw->mac.ops.set_rar(hw, 0, hw->mac.addr, 0, IXGBE_RAH_AV);
 	}
@@ -1296,19 +1295,19 @@ static s32 ixgbe_mta_vector(struct ixgbe_hw *hw, u8 *mc_addr)
 	u32 vector = 0;
 
 	switch (hw->mac.mc_filter_type) {
-	case 0:	  /* use bits [47:36] of the address */
+	case 0:   /* use bits [47:36] of the address */
 		vector = ((mc_addr[4] >> 4) | (((u16)mc_addr[5]) << 4));
 		break;
-	case 1:	  /* use bits [46:35] of the address */
+	case 1:   /* use bits [46:35] of the address */
 		vector = ((mc_addr[4] >> 3) | (((u16)mc_addr[5]) << 5));
 		break;
-	case 2:	  /* use bits [45:34] of the address */
+	case 2:   /* use bits [45:34] of the address */
 		vector = ((mc_addr[4] >> 2) | (((u16)mc_addr[5]) << 6));
 		break;
-	case 3:	  /* use bits [43:32] of the address */
+	case 3:   /* use bits [43:32] of the address */
 		vector = ((mc_addr[4]) | (((u16)mc_addr[5]) << 8));
 		break;
-	default:	 /* Invalid mc_filter_type */
+	default:  /* Invalid mc_filter_type */
 		hw_dbg(hw, "MC filter type param set incorrectly\n");
 		break;
 	}
@@ -1366,8 +1365,8 @@ static void ixgbe_add_mc_addr(struct ixgbe_hw *hw, u8 *mc_addr)
 	u32 rar;
 
 	hw_dbg(hw, " MC Addr =%.2X %.2X %.2X %.2X %.2X %.2X\n",
-		  mc_addr[0], mc_addr[1], mc_addr[2],
-		  mc_addr[3], mc_addr[4], mc_addr[5]);
+	       mc_addr[0], mc_addr[1], mc_addr[2],
+	       mc_addr[3], mc_addr[4], mc_addr[5]);
 
 	/*
 	 * Place this multicast address in the RAR if there is room,
@@ -1400,7 +1399,7 @@ static void ixgbe_add_mc_addr(struct ixgbe_hw *hw, u8 *mc_addr)
  *  multicast table.
  **/
 s32 ixgbe_update_mc_addr_list_generic(struct ixgbe_hw *hw, u8 *mc_addr_list,
-			      u32 mc_addr_count, ixgbe_mc_addr_itr next)
+                                      u32 mc_addr_count, ixgbe_mc_addr_itr next)
 {
 	u32 i;
 	u32 rar_entries = hw->mac.num_rar_entries;
@@ -1437,7 +1436,7 @@ s32 ixgbe_update_mc_addr_list_generic(struct ixgbe_hw *hw, u8 *mc_addr_list,
 	/* Enable mta */
 	if (hw->addr_ctrl.mta_in_use > 0)
 		IXGBE_WRITE_REG(hw, IXGBE_MCSTCTRL,
-				IXGBE_MCSTCTRL_MFE | hw->mac.mc_filter_type);
+		                IXGBE_MCSTCTRL_MFE | hw->mac.mc_filter_type);
 
 	hw_dbg(hw, "ixgbe_update_mc_addr_list_generic Complete\n");
 	return 0;
diff --git a/drivers/net/ixgbe/ixgbe_common.h b/drivers/net/ixgbe/ixgbe_common.h
index 13ed8d2..192f8d0 100644
--- a/drivers/net/ixgbe/ixgbe_common.h
+++ b/drivers/net/ixgbe/ixgbe_common.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2007 Intel Corporation.
+  Copyright(c) 1999 - 2008 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -20,7 +20,6 @@
   the file called "COPYING".
 
   Contact Information:
-  Linux NICS <linux.nics@intel.com>
   e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
   Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
 
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 020b0c7..81a9c4b 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2007 Intel Corporation.
+  Copyright(c) 1999 - 2008 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -20,7 +20,6 @@
   the file called "COPYING".
 
   Contact Information:
-  Linux NICS <linux.nics@intel.com>
   e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
   Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
 
@@ -48,7 +47,7 @@ struct ixgbe_stats {
 };
 
 #define IXGBE_STAT(m) sizeof(((struct ixgbe_adapter *)0)->m), \
-		      offsetof(struct ixgbe_adapter, m)
+                             offsetof(struct ixgbe_adapter, m)
 static struct ixgbe_stats ixgbe_gstrings_stats[] = {
 	{"rx_packets", IXGBE_STAT(net_stats.rx_packets)},
 	{"tx_packets", IXGBE_STAT(net_stats.tx_packets)},
@@ -95,14 +94,15 @@ static struct ixgbe_stats ixgbe_gstrings_stats[] = {
 };
 
 #define IXGBE_QUEUE_STATS_LEN \
-		((((struct ixgbe_adapter *)netdev->priv)->num_tx_queues + \
-		 ((struct ixgbe_adapter *)netdev->priv)->num_rx_queues) * \
-		 (sizeof(struct ixgbe_queue_stats) / sizeof(u64)))
-#define IXGBE_GLOBAL_STATS_LEN	ARRAY_SIZE(ixgbe_gstrings_stats)
+                ((((struct ixgbe_adapter *)netdev->priv)->num_tx_queues + \
+                 ((struct ixgbe_adapter *)netdev->priv)->num_rx_queues) * \
+                 (sizeof(struct ixgbe_queue_stats) / sizeof(u64)))
+#define IXGBE_STATS_LEN (IXGBE_GLOBAL_STATS_LEN + IXGBE_QUEUE_STATS_LEN)
+#define IXGBE_GLOBAL_STATS_LEN ARRAY_SIZE(ixgbe_gstrings_stats)
 #define IXGBE_STATS_LEN (IXGBE_GLOBAL_STATS_LEN + IXGBE_QUEUE_STATS_LEN)
 
 static int ixgbe_get_settings(struct net_device *netdev,
-			      struct ethtool_cmd *ecmd)
+                              struct ethtool_cmd *ecmd)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
@@ -114,7 +114,7 @@ static int ixgbe_get_settings(struct net_device *netdev,
 	ecmd->transceiver = XCVR_EXTERNAL;
 	if (hw->phy.media_type == ixgbe_media_type_copper) {
 		ecmd->supported |= (SUPPORTED_1000baseT_Full |
-				    SUPPORTED_TP | SUPPORTED_Autoneg);
+		                    SUPPORTED_TP | SUPPORTED_Autoneg);
 
 		ecmd->advertising = (ADVERTISED_TP | ADVERTISED_Autoneg);
 		if (hw->phy.autoneg_advertised & IXGBE_LINK_SPEED_10GB_FULL)
@@ -126,7 +126,7 @@ static int ixgbe_get_settings(struct net_device *netdev,
 	} else {
 		ecmd->supported |= SUPPORTED_FIBRE;
 		ecmd->advertising = (ADVERTISED_10000baseT_Full |
-				     ADVERTISED_FIBRE);
+		                     ADVERTISED_FIBRE);
 		ecmd->port = PORT_FIBRE;
 		ecmd->autoneg = AUTONEG_DISABLE;
 	}
@@ -134,7 +134,7 @@ static int ixgbe_get_settings(struct net_device *netdev,
 	hw->mac.ops.check_link(hw, &link_speed, &link_up, false);
 	if (link_up) {
 		ecmd->speed = (link_speed == IXGBE_LINK_SPEED_10GB_FULL) ?
-				SPEED_10000 : SPEED_1000;
+		               SPEED_10000 : SPEED_1000;
 		ecmd->duplex = DUPLEX_FULL;
 	} else {
 		ecmd->speed = -1;
@@ -145,7 +145,7 @@ static int ixgbe_get_settings(struct net_device *netdev,
 }
 
 static int ixgbe_set_settings(struct net_device *netdev,
-			      struct ethtool_cmd *ecmd)
+                              struct ethtool_cmd *ecmd)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
@@ -165,7 +165,7 @@ static int ixgbe_set_settings(struct net_device *netdev,
 }
 
 static void ixgbe_get_pauseparam(struct net_device *netdev,
-				 struct ethtool_pauseparam *pause)
+                                 struct ethtool_pauseparam *pause)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
@@ -183,7 +183,7 @@ static void ixgbe_get_pauseparam(struct net_device *netdev,
 }
 
 static int ixgbe_set_pauseparam(struct net_device *netdev,
-				struct ethtool_pauseparam *pause)
+                                struct ethtool_pauseparam *pause)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
@@ -282,7 +282,7 @@ static int ixgbe_get_regs_len(struct net_device *netdev)
 #define IXGBE_GET_STAT(_A_, _R_) _A_->stats._R_
 
 static void ixgbe_get_regs(struct net_device *netdev,
-			   struct ethtool_regs *regs, void *p)
+                           struct ethtool_regs *regs, void *p)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
@@ -583,7 +583,7 @@ static int ixgbe_get_eeprom_len(struct net_device *netdev)
 }
 
 static int ixgbe_get_eeprom(struct net_device *netdev,
-			    struct ethtool_eeprom *eeprom, u8 *bytes)
+                            struct ethtool_eeprom *eeprom, u8 *bytes)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
@@ -607,7 +607,7 @@ static int ixgbe_get_eeprom(struct net_device *netdev,
 
 	for (i = 0; i < eeprom_len; i++) {
 		if ((ret_val = hw->eeprom.ops.read(hw, first_word + i,
-						   &eeprom_buff[i])))
+		    &eeprom_buff[i])))
 			break;
 	}
 
@@ -622,7 +622,7 @@ static int ixgbe_get_eeprom(struct net_device *netdev,
 }
 
 static void ixgbe_get_drvinfo(struct net_device *netdev,
-			      struct ethtool_drvinfo *drvinfo)
+                              struct ethtool_drvinfo *drvinfo)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 
@@ -635,7 +635,7 @@ static void ixgbe_get_drvinfo(struct net_device *netdev,
 }
 
 static void ixgbe_get_ringparam(struct net_device *netdev,
-				struct ethtool_ringparam *ring)
+                                struct ethtool_ringparam *ring)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_ring *tx_ring = adapter->tx_ring;
@@ -652,7 +652,7 @@ static void ixgbe_get_ringparam(struct net_device *netdev,
 }
 
 static int ixgbe_set_ringparam(struct net_device *netdev,
-			       struct ethtool_ringparam *ring)
+                               struct ethtool_ringparam *ring)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_ring *temp_ring;
@@ -706,7 +706,8 @@ static int ixgbe_set_ringparam(struct net_device *netdev,
 			if (err) {
 				while (i) {
 					i--;
-					ixgbe_free_tx_resources(adapter, &temp_ring[i]);
+					ixgbe_free_tx_resources(adapter,
+					                        &temp_ring[i]);
 				}
 				goto err_setup;
 			}
@@ -731,7 +732,8 @@ static int ixgbe_set_ringparam(struct net_device *netdev,
 			if (err) {
 				while (i) {
 					i--;
-					ixgbe_free_rx_resources(adapter, &temp_ring[i]);
+					ixgbe_free_rx_resources(adapter,
+					                        &temp_ring[i]);
 				}
 				goto err_setup;
 			}
@@ -767,7 +769,7 @@ static int ixgbe_get_sset_count(struct net_device *netdev, int sset)
 }
 
 static void ixgbe_get_ethtool_stats(struct net_device *netdev,
-				    struct ethtool_stats *stats, u64 *data)
+                                    struct ethtool_stats *stats, u64 *data)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	u64 *queue_stat;
@@ -788,7 +790,7 @@ static void ixgbe_get_ethtool_stats(struct net_device *netdev,
 	for (i = 0; i < IXGBE_GLOBAL_STATS_LEN; i++) {
 		char *p = (char *)adapter + ixgbe_gstrings_stats[i].stat_offset;
 		data[i] = (ixgbe_gstrings_stats[i].sizeof_stat ==
-			   sizeof(u64)) ? *(u64 *)p : *(u32 *)p;
+		           sizeof(u64)) ? *(u64 *)p : *(u32 *)p;
 	}
 	for (j = 0; j < adapter->num_tx_queues; j++) {
 		queue_stat = (u64 *)&adapter->tx_ring[j].stats;
@@ -805,7 +807,7 @@ static void ixgbe_get_ethtool_stats(struct net_device *netdev,
 }
 
 static void ixgbe_get_strings(struct net_device *netdev, u32 stringset,
-			      u8 *data)
+                              u8 *data)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	char *p = (char *)data;
@@ -830,14 +832,14 @@ static void ixgbe_get_strings(struct net_device *netdev, u32 stringset,
 			sprintf(p, "rx_queue_%u_bytes", i);
 			p += ETH_GSTRING_LEN;
 		}
-/*		BUG_ON(p - data != IXGBE_STATS_LEN * ETH_GSTRING_LEN); */
+		/* BUG_ON(p - data != IXGBE_STATS_LEN * ETH_GSTRING_LEN); */
 		break;
 	}
 }
 
 
 static void ixgbe_get_wol(struct net_device *netdev,
-			  struct ethtool_wolinfo *wol)
+                          struct ethtool_wolinfo *wol)
 {
 	wol->supported = 0;
 	wol->wolopts = 0;
@@ -879,7 +881,7 @@ static int ixgbe_phys_id(struct net_device *netdev, u32 data)
 }
 
 static int ixgbe_get_coalesce(struct net_device *netdev,
-			      struct ethtool_coalesce *ec)
+                              struct ethtool_coalesce *ec)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 
@@ -904,7 +906,7 @@ static int ixgbe_get_coalesce(struct net_device *netdev,
 }
 
 static int ixgbe_set_coalesce(struct net_device *netdev,
-			      struct ethtool_coalesce *ec)
+                              struct ethtool_coalesce *ec)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
@@ -974,7 +976,7 @@ static const struct ethtool_ops ixgbe_ethtool_ops = {
 	.set_tso                = ixgbe_set_tso,
 	.get_strings            = ixgbe_get_strings,
 	.phys_id                = ixgbe_phys_id,
-	.get_sset_count		= ixgbe_get_sset_count,
+	.get_sset_count         = ixgbe_get_sset_count,
 	.get_ethtool_stats      = ixgbe_get_ethtool_stats,
 	.get_coalesce           = ixgbe_get_coalesce,
 	.set_coalesce           = ixgbe_set_coalesce,
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index b513911..2980a37 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2007 Intel Corporation.
+  Copyright(c) 1999 - 2008 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -20,7 +20,6 @@
   the file called "COPYING".
 
   Contact Information:
-  Linux NICS <linux.nics@intel.com>
   e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
   Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
 
@@ -46,15 +45,14 @@
 
 char ixgbe_driver_name[] = "ixgbe";
 static const char ixgbe_driver_string[] =
-	"Intel(R) 10 Gigabit PCI Express Network Driver";
+                              "Intel(R) 10 Gigabit PCI Express Network Driver";
 
 #define DRV_VERSION "1.3.30-k2"
 const char ixgbe_driver_version[] = DRV_VERSION;
-static const char ixgbe_copyright[] =
-	 "Copyright (c) 1999-2007 Intel Corporation.";
+static char ixgbe_copyright[] = "Copyright (c) 1999-2007 Intel Corporation.";
 
 static const struct ixgbe_info *ixgbe_info_tbl[] = {
-	[board_82598]			= &ixgbe_82598_info,
+	[board_82598] = &ixgbe_82598_info,
 };
 
 /* ixgbe_pci_tbl - PCI Device ID Table
@@ -84,7 +82,7 @@ MODULE_DEVICE_TABLE(pci, ixgbe_pci_tbl);
 
 #if defined(CONFIG_DCA) || defined(CONFIG_DCA_MODULE)
 static int ixgbe_notify_dca(struct notifier_block *, unsigned long event,
-			    void *p);
+                            void *p);
 static struct notifier_block dca_notifier = {
 	.notifier_call = ixgbe_notify_dca,
 	.next          = NULL,
@@ -106,7 +104,7 @@ static void ixgbe_release_hw_control(struct ixgbe_adapter *adapter)
 	/* Let firmware take over control of h/w */
 	ctrl_ext = IXGBE_READ_REG(&adapter->hw, IXGBE_CTRL_EXT);
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_CTRL_EXT,
-			ctrl_ext & ~IXGBE_CTRL_EXT_DRV_LOAD);
+	                ctrl_ext & ~IXGBE_CTRL_EXT_DRV_LOAD);
 }
 
 static void ixgbe_get_hw_control(struct ixgbe_adapter *adapter)
@@ -116,7 +114,7 @@ static void ixgbe_get_hw_control(struct ixgbe_adapter *adapter)
 	/* Let firmware know the driver has taken over */
 	ctrl_ext = IXGBE_READ_REG(&adapter->hw, IXGBE_CTRL_EXT);
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_CTRL_EXT,
-			ctrl_ext | IXGBE_CTRL_EXT_DRV_LOAD);
+	                ctrl_ext | IXGBE_CTRL_EXT_DRV_LOAD);
 }
 
 #ifdef DEBUG
@@ -133,7 +131,7 @@ char *ixgbe_get_hw_dev_name(struct ixgbe_hw *hw)
 #endif
 
 static void ixgbe_set_ivar(struct ixgbe_adapter *adapter, u16 int_alloc_entry,
-			   u8 msix_vector)
+                           u8 msix_vector)
 {
 	u32 ivar, index;
 
@@ -146,12 +144,12 @@ static void ixgbe_set_ivar(struct ixgbe_adapter *adapter, u16 int_alloc_entry,
 }
 
 static void ixgbe_unmap_and_free_tx_resource(struct ixgbe_adapter *adapter,
-					     struct ixgbe_tx_buffer
-					     *tx_buffer_info)
+                                             struct ixgbe_tx_buffer
+                                             *tx_buffer_info)
 {
 	if (tx_buffer_info->dma) {
 		pci_unmap_page(adapter->pdev, tx_buffer_info->dma,
-			       tx_buffer_info->length, PCI_DMA_TODEVICE);
+		               tx_buffer_info->length, PCI_DMA_TODEVICE);
 		tx_buffer_info->dma = 0;
 	}
 	if (tx_buffer_info->skb) {
@@ -162,8 +160,8 @@ static void ixgbe_unmap_and_free_tx_resource(struct ixgbe_adapter *adapter,
 }
 
 static inline bool ixgbe_check_tx_hang(struct ixgbe_adapter *adapter,
-				       struct ixgbe_ring *tx_ring,
-				       unsigned int eop)
+                                       struct ixgbe_ring *tx_ring,
+                                       unsigned int eop)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
 	u32 head, tail;
@@ -198,14 +196,14 @@ static inline bool ixgbe_check_tx_hang(struct ixgbe_adapter *adapter,
 	return false;
 }
 
-#define IXGBE_MAX_TXD_PWR	14
-#define IXGBE_MAX_DATA_PER_TXD	(1 << IXGBE_MAX_TXD_PWR)
+#define IXGBE_MAX_TXD_PWR       14
+#define IXGBE_MAX_DATA_PER_TXD  (1 << IXGBE_MAX_TXD_PWR)
 
 /* Tx Descriptors needed, worst case */
 #define TXD_USE_COUNT(S) (((S) >> IXGBE_MAX_TXD_PWR) + \
 			 (((S) & (IXGBE_MAX_DATA_PER_TXD - 1)) ? 1 : 0))
 #define DESC_NEEDED (TXD_USE_COUNT(IXGBE_MAX_DATA_PER_TXD) /* skb->data */ + \
-	MAX_SKB_FRAGS * TXD_USE_COUNT(PAGE_SIZE) + 1)	/* for context */
+	MAX_SKB_FRAGS * TXD_USE_COUNT(PAGE_SIZE) + 1) /* for context */
 
 #define GET_TX_HEAD_FROM_RING(ring) (\
 	*(volatile u32 *) \
@@ -313,7 +311,7 @@ done_cleaning:
 
 #if defined(CONFIG_DCA) || defined(CONFIG_DCA_MODULE)
 static void ixgbe_update_rx_dca(struct ixgbe_adapter *adapter,
-				struct ixgbe_ring *rx_ring)
+                                struct ixgbe_ring *rx_ring)
 {
 	u32 rxctrl;
 	int cpu = get_cpu();
@@ -332,7 +330,7 @@ static void ixgbe_update_rx_dca(struct ixgbe_adapter *adapter,
 }
 
 static void ixgbe_update_tx_dca(struct ixgbe_adapter *adapter,
-				struct ixgbe_ring *tx_ring)
+                                struct ixgbe_ring *tx_ring)
 {
 	u32 txctrl;
 	int cpu = get_cpu();
@@ -408,8 +406,8 @@ static int __ixgbe_notify_dca(struct device *dev, void *data)
  * @rx_desc: rx descriptor
  **/
 static void ixgbe_receive_skb(struct ixgbe_adapter *adapter,
-			      struct sk_buff *skb, u8 status,
-			      struct ixgbe_ring *ring,
+                              struct sk_buff *skb, u8 status,
+                              struct ixgbe_ring *ring,
                               union ixgbe_adv_rx_desc *rx_desc)
 {
 	bool is_vlan = (status & IXGBE_RXD_STAT_VP);
@@ -577,8 +575,8 @@ static inline u16 ixgbe_get_pkt_info(union ixgbe_adv_rx_desc *rx_desc)
 }
 
 static bool ixgbe_clean_rx_irq(struct ixgbe_adapter *adapter,
-	                       struct ixgbe_ring *rx_ring,
-	                       int *work_done, int work_to_do)
+                               struct ixgbe_ring *rx_ring,
+                               int *work_done, int work_to_do)
 {
 	struct pci_dev *pdev = adapter->pdev;
 	union ixgbe_adv_rx_desc *rx_desc, *next_rxd;
@@ -622,8 +620,8 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_adapter *adapter,
 
 		if (len && !skb_shinfo(skb)->nr_frags) {
 			pci_unmap_single(pdev, rx_buffer_info->dma,
-	                                 rx_ring->rx_buf_len + NET_IP_ALIGN,
-	                                 PCI_DMA_FROMDEVICE);
+			                 rx_ring->rx_buf_len + NET_IP_ALIGN,
+			                 PCI_DMA_FROMDEVICE);
 			skb_put(skb, len);
 		}
 
@@ -741,24 +739,24 @@ static void ixgbe_configure_msix(struct ixgbe_adapter *adapter)
 		q_vector = &adapter->q_vector[v_idx];
 		/* XXX for_each_bit(...) */
 		r_idx = find_first_bit(q_vector->rxr_idx,
-				      adapter->num_rx_queues);
+		                       adapter->num_rx_queues);
 
 		for (i = 0; i < q_vector->rxr_count; i++) {
 			j = adapter->rx_ring[r_idx].reg_idx;
 			ixgbe_set_ivar(adapter, IXGBE_IVAR_RX_QUEUE(j), v_idx);
 			r_idx = find_next_bit(q_vector->rxr_idx,
-					      adapter->num_rx_queues,
-					      r_idx + 1);
+			                      adapter->num_rx_queues,
+			                      r_idx + 1);
 		}
 		r_idx = find_first_bit(q_vector->txr_idx,
-				       adapter->num_tx_queues);
+		                       adapter->num_tx_queues);
 
 		for (i = 0; i < q_vector->txr_count; i++) {
 			j = adapter->tx_ring[r_idx].reg_idx;
 			ixgbe_set_ivar(adapter, IXGBE_IVAR_TX_QUEUE(j), v_idx);
 			r_idx = find_next_bit(q_vector->txr_idx,
-					      adapter->num_tx_queues,
-					      r_idx + 1);
+			                      adapter->num_tx_queues,
+			                      r_idx + 1);
 		}
 
 		/* if this is a tx only vector halve the interrupt rate */
@@ -769,7 +767,7 @@ static void ixgbe_configure_msix(struct ixgbe_adapter *adapter)
 			q_vector->eitr = adapter->eitr_param;
 
 		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EITR(v_idx),
-				EITR_INTS_PER_SEC_TO_REG(q_vector->eitr));
+		                EITR_INTS_PER_SEC_TO_REG(q_vector->eitr));
 	}
 
 	ixgbe_set_ivar(adapter, IXGBE_IVAR_OTHER_CAUSES_INDEX, v_idx);
@@ -807,8 +805,8 @@ enum latency_range {
  *      parameter (see ixgbe_param.c)
  **/
 static u8 ixgbe_update_itr(struct ixgbe_adapter *adapter,
-			   u32 eitr, u8 itr_setting,
-			   int packets, int bytes)
+                           u32 eitr, u8 itr_setting,
+                           int packets, int bytes)
 {
 	unsigned int retval = itr_setting;
 	u32 timepassed_us;
@@ -855,37 +853,37 @@ static void ixgbe_set_itr_msix(struct ixgbe_q_vector *q_vector)
 	u32 new_itr;
 	u8 current_itr, ret_itr;
 	int i, r_idx, v_idx = ((void *)q_vector - (void *)(adapter->q_vector)) /
-			      sizeof(struct ixgbe_q_vector);
+	                       sizeof(struct ixgbe_q_vector);
 	struct ixgbe_ring *rx_ring, *tx_ring;
 
 	r_idx = find_first_bit(q_vector->txr_idx, adapter->num_tx_queues);
 	for (i = 0; i < q_vector->txr_count; i++) {
 		tx_ring = &(adapter->tx_ring[r_idx]);
 		ret_itr = ixgbe_update_itr(adapter, q_vector->eitr,
-					   q_vector->tx_itr,
-					   tx_ring->total_packets,
-					   tx_ring->total_bytes);
+		                           q_vector->tx_itr,
+		                           tx_ring->total_packets,
+		                           tx_ring->total_bytes);
 		/* if the result for this queue would decrease interrupt
 		 * rate for this vector then use that result */
 		q_vector->tx_itr = ((q_vector->tx_itr > ret_itr) ?
-				    q_vector->tx_itr - 1 : ret_itr);
+		                    q_vector->tx_itr - 1 : ret_itr);
 		r_idx = find_next_bit(q_vector->txr_idx, adapter->num_tx_queues,
-				      r_idx + 1);
+		                      r_idx + 1);
 	}
 
 	r_idx = find_first_bit(q_vector->rxr_idx, adapter->num_rx_queues);
 	for (i = 0; i < q_vector->rxr_count; i++) {
 		rx_ring = &(adapter->rx_ring[r_idx]);
 		ret_itr = ixgbe_update_itr(adapter, q_vector->eitr,
-					   q_vector->rx_itr,
-					   rx_ring->total_packets,
-					   rx_ring->total_bytes);
+		                           q_vector->rx_itr,
+		                           rx_ring->total_packets,
+		                           rx_ring->total_bytes);
 		/* if the result for this queue would decrease interrupt
 		 * rate for this vector then use that result */
 		q_vector->rx_itr = ((q_vector->rx_itr > ret_itr) ?
-				    q_vector->rx_itr - 1 : ret_itr);
+		                    q_vector->rx_itr - 1 : ret_itr);
 		r_idx = find_next_bit(q_vector->rxr_idx, adapter->num_rx_queues,
-				      r_idx + 1);
+		                      r_idx + 1);
 	}
 
 	current_itr = max(q_vector->rx_itr, q_vector->tx_itr);
@@ -912,7 +910,7 @@ static void ixgbe_set_itr_msix(struct ixgbe_q_vector *q_vector)
 		itr_reg = EITR_INTS_PER_SEC_TO_REG(new_itr);
 		/* must write high and low 16 bits to reset counter */
 		DPRINTK(TX_ERR, DEBUG, "writing eitr(%d): %08X\n", v_idx,
-			itr_reg);
+		        itr_reg);
 		IXGBE_WRITE_REG(hw, IXGBE_EITR(v_idx), itr_reg | (itr_reg)<<16);
 	}
 
@@ -970,7 +968,7 @@ static irqreturn_t ixgbe_msix_clean_tx(int irq, void *data)
 		tx_ring->total_packets = 0;
 		ixgbe_clean_tx_irq(adapter, tx_ring);
 		r_idx = find_next_bit(q_vector->txr_idx, adapter->num_tx_queues,
-				      r_idx + 1);
+		                      r_idx + 1);
 	}
 
 	return IRQ_HANDLED;
@@ -1029,7 +1027,7 @@ static irqreturn_t ixgbe_msix_clean_many(int irq, void *data)
 static int ixgbe_clean_rxonly(struct napi_struct *napi, int budget)
 {
 	struct ixgbe_q_vector *q_vector =
-			       container_of(napi, struct ixgbe_q_vector, napi);
+	                       container_of(napi, struct ixgbe_q_vector, napi);
 	struct ixgbe_adapter *adapter = q_vector->adapter;
 	struct ixgbe_ring *rx_ring = NULL;
 	int work_done = 0;
@@ -1106,7 +1104,7 @@ static int ixgbe_clean_rxonly_many(struct napi_struct *napi, int budget)
 	return work_done;
 }
 static inline void map_vector_to_rxq(struct ixgbe_adapter *a, int v_idx,
-				     int r_idx)
+                                     int r_idx)
 {
 	a->q_vector[v_idx].adapter = a;
 	set_bit(r_idx, a->q_vector[v_idx].rxr_idx);
@@ -1115,7 +1113,7 @@ static inline void map_vector_to_rxq(struct ixgbe_adapter *a, int v_idx,
 }
 
 static inline void map_vector_to_txq(struct ixgbe_adapter *a, int v_idx,
-				     int r_idx)
+                                     int r_idx)
 {
 	a->q_vector[v_idx].adapter = a;
 	set_bit(r_idx, a->q_vector[v_idx].txr_idx);
@@ -1135,7 +1133,7 @@ static inline void map_vector_to_txq(struct ixgbe_adapter *a, int v_idx,
  * mapping configurations in here.
  **/
 static int ixgbe_map_rings_to_vectors(struct ixgbe_adapter *adapter,
-				      int vectors)
+                                      int vectors)
 {
 	int v_start = 0;
 	int rxr_idx = 0, txr_idx = 0;
@@ -1212,28 +1210,28 @@ static int ixgbe_request_msix_irqs(struct ixgbe_adapter *adapter)
 		goto out;
 
 #define SET_HANDLER(_v) ((!(_v)->rxr_count) ? &ixgbe_msix_clean_tx : \
-			 (!(_v)->txr_count) ? &ixgbe_msix_clean_rx : \
-			 &ixgbe_msix_clean_many)
+                         (!(_v)->txr_count) ? &ixgbe_msix_clean_rx : \
+                         &ixgbe_msix_clean_many)
 	for (vector = 0; vector < q_vectors; vector++) {
 		handler = SET_HANDLER(&adapter->q_vector[vector]);
 		sprintf(adapter->name[vector], "%s:v%d-%s",
-			netdev->name, vector,
-			(handler == &ixgbe_msix_clean_rx) ? "Rx" :
-			 ((handler == &ixgbe_msix_clean_tx) ? "Tx" : "TxRx"));
+		        netdev->name, vector,
+		        (handler == &ixgbe_msix_clean_rx) ? "Rx" :
+		         ((handler == &ixgbe_msix_clean_tx) ? "Tx" : "TxRx"));
 		err = request_irq(adapter->msix_entries[vector].vector,
-				  handler, 0, adapter->name[vector],
-				  &(adapter->q_vector[vector]));
+		                  handler, 0, adapter->name[vector],
+		                  &(adapter->q_vector[vector]));
 		if (err) {
 			DPRINTK(PROBE, ERR,
-				"request_irq failed for MSIX interrupt "
-				"Error: %d\n", err);
+			        "request_irq failed for MSIX interrupt "
+			        "Error: %d\n", err);
 			goto free_queue_irqs;
 		}
 	}
 
 	sprintf(adapter->name[vector], "%s:lsc", netdev->name);
 	err = request_irq(adapter->msix_entries[vector].vector,
-			  &ixgbe_msix_lsc, 0, adapter->name[vector], netdev);
+	                  &ixgbe_msix_lsc, 0, adapter->name[vector], netdev);
 	if (err) {
 		DPRINTK(PROBE, ERR,
 			"request_irq for msix_lsc failed: %d\n", err);
@@ -1245,7 +1243,7 @@ static int ixgbe_request_msix_irqs(struct ixgbe_adapter *adapter)
 free_queue_irqs:
 	for (i = vector - 1; i >= 0; i--)
 		free_irq(adapter->msix_entries[--vector].vector,
-			 &(adapter->q_vector[i]));
+		         &(adapter->q_vector[i]));
 	adapter->flags &= ~IXGBE_FLAG_MSIX_ENABLED;
 	pci_disable_msix(adapter->pdev);
 	kfree(adapter->msix_entries);
@@ -1264,13 +1262,13 @@ static void ixgbe_set_itr(struct ixgbe_adapter *adapter)
 	struct ixgbe_ring *tx_ring = &adapter->tx_ring[0];
 
 	q_vector->tx_itr = ixgbe_update_itr(adapter, new_itr,
-					    q_vector->tx_itr,
-					    tx_ring->total_packets,
-					    tx_ring->total_bytes);
+	                                    q_vector->tx_itr,
+	                                    tx_ring->total_packets,
+	                                    tx_ring->total_bytes);
 	q_vector->rx_itr = ixgbe_update_itr(adapter, new_itr,
-					    q_vector->rx_itr,
-					    rx_ring->total_packets,
-					    rx_ring->total_bytes);
+	                                    q_vector->rx_itr,
+	                                    rx_ring->total_packets,
+	                                    rx_ring->total_bytes);
 
 	current_itr = max(q_vector->rx_itr, q_vector->tx_itr);
 
@@ -1373,10 +1371,10 @@ static int ixgbe_request_irq(struct ixgbe_adapter *adapter)
 		err = ixgbe_request_msix_irqs(adapter);
 	} else if (adapter->flags & IXGBE_FLAG_MSI_ENABLED) {
 		err = request_irq(adapter->pdev->irq, &ixgbe_intr, 0,
-				  netdev->name, netdev);
+		                  netdev->name, netdev);
 	} else {
 		err = request_irq(adapter->pdev->irq, &ixgbe_intr, IRQF_SHARED,
-				  netdev->name, netdev);
+		                  netdev->name, netdev);
 	}
 
 	if (err)
@@ -1400,7 +1398,7 @@ static void ixgbe_free_irq(struct ixgbe_adapter *adapter)
 		i--;
 		for (; i >= 0; i--) {
 			free_irq(adapter->msix_entries[i].vector,
-				 &(adapter->q_vector[i]));
+			         &(adapter->q_vector[i]));
 		}
 
 		ixgbe_reset_q_vectors(adapter);
@@ -1533,8 +1531,8 @@ static void ixgbe_configure_srrctl(struct ixgbe_adapter *adapter, int index)
 		srrctl |= IXGBE_RXBUFFER_2048 >> IXGBE_SRRCTL_BSIZEPKT_SHIFT;
 		srrctl |= IXGBE_SRRCTL_DESCTYPE_HDR_SPLIT_ALWAYS;
 		srrctl |= ((IXGBE_RX_HDR_SIZE <<
-			    IXGBE_SRRCTL_BSIZEHDRSIZE_SHIFT) &
-			   IXGBE_SRRCTL_BSIZEHDR_MASK);
+		            IXGBE_SRRCTL_BSIZEHDRSIZE_SHIFT) &
+		           IXGBE_SRRCTL_BSIZEHDR_MASK);
 	} else {
 		srrctl |= IXGBE_SRRCTL_DESCTYPE_ADV_ONEBUF;
 
@@ -1551,7 +1549,7 @@ static void ixgbe_configure_srrctl(struct ixgbe_adapter *adapter, int index)
 /**
  * ixgbe_get_skb_hdr - helper function for LRO header processing
  * @skb: pointer to sk_buff to be added to LRO packet
- * @iphdr: pointer to tcp header structure
+ * @iphdr: pointer to ip header structure
  * @tcph: pointer to tcp header structure
  * @hdr_flags: pointer to header flags
  * @priv: private data
@@ -1576,7 +1574,7 @@ static int ixgbe_get_skb_hdr(struct sk_buff *skb, void **iphdr, void **tcph,
 }
 
 #define PAGE_USE_COUNT(S) (((S) >> PAGE_SHIFT) + \
-			(((S) & (PAGE_SIZE - 1)) ? 1 : 0))
+                           (((S) & (PAGE_SIZE - 1)) ? 1 : 0))
 
 /**
  * ixgbe_configure_rx - Configure 8259x Receive Unit after Reset
@@ -1723,7 +1721,7 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 }
 
 static void ixgbe_vlan_rx_register(struct net_device *netdev,
-				   struct vlan_group *grp)
+                                   struct vlan_group *grp)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	u32 ctrl;
@@ -1909,7 +1907,7 @@ static void ixgbe_configure(struct ixgbe_adapter *adapter)
 	ixgbe_configure_rx(adapter);
 	for (i = 0; i < adapter->num_rx_queues; i++)
 		ixgbe_alloc_rx_buffers(adapter, &adapter->rx_ring[i],
-					   (adapter->rx_ring[i].count - 1));
+		                       (adapter->rx_ring[i].count - 1));
 }
 
 static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
@@ -1927,7 +1925,7 @@ static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
 	    (adapter->flags & IXGBE_FLAG_MSI_ENABLED)) {
 		if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED) {
 			gpie = (IXGBE_GPIE_MSIX_MODE | IXGBE_GPIE_EIAME |
-				IXGBE_GPIE_PBA_SUPPORT | IXGBE_GPIE_OCD);
+			        IXGBE_GPIE_PBA_SUPPORT | IXGBE_GPIE_OCD);
 		} else {
 			/* MSI only */
 			gpie = 0;
@@ -2037,7 +2035,7 @@ static int ixgbe_resume(struct pci_dev *pdev)
 	err = pci_enable_device(pdev);
 	if (err) {
 		printk(KERN_ERR "ixgbe: Cannot enable PCI device from " \
-				"suspend\n");
+		       "suspend\n");
 		return err;
 	}
 	pci_set_master(pdev);
@@ -2068,7 +2066,7 @@ static int ixgbe_resume(struct pci_dev *pdev)
  * @rx_ring: ring to free buffers from
  **/
 static void ixgbe_clean_rx_ring(struct ixgbe_adapter *adapter,
-				struct ixgbe_ring *rx_ring)
+                                struct ixgbe_ring *rx_ring)
 {
 	struct pci_dev *pdev = adapter->pdev;
 	unsigned long size;
@@ -2082,8 +2080,8 @@ static void ixgbe_clean_rx_ring(struct ixgbe_adapter *adapter,
 		rx_buffer_info = &rx_ring->rx_buffer_info[i];
 		if (rx_buffer_info->dma) {
 			pci_unmap_single(pdev, rx_buffer_info->dma,
-					 rx_ring->rx_buf_len,
-					 PCI_DMA_FROMDEVICE);
+			                 rx_ring->rx_buf_len,
+			                 PCI_DMA_FROMDEVICE);
 			rx_buffer_info->dma = 0;
 		}
 		if (rx_buffer_info->skb) {
@@ -2119,7 +2117,7 @@ static void ixgbe_clean_rx_ring(struct ixgbe_adapter *adapter,
  * @tx_ring: ring to be cleaned
  **/
 static void ixgbe_clean_tx_ring(struct ixgbe_adapter *adapter,
-				struct ixgbe_ring *tx_ring)
+                                struct ixgbe_ring *tx_ring)
 {
 	struct ixgbe_tx_buffer *tx_buffer_info;
 	unsigned long size;
@@ -2226,7 +2224,7 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 		adapter->flags |= IXGBE_FLAG_DCA_ENABLED;
 		/* always use CB2 mode, difference is masked
 		 * in the CB driver */
-			IXGBE_WRITE_REG(hw, IXGBE_DCA_CTRL, 2);
+		IXGBE_WRITE_REG(hw, IXGBE_DCA_CTRL, 2);
 		ixgbe_setup_dca(adapter);
 	}
 #endif
@@ -2280,7 +2278,7 @@ static void ixgbe_shutdown(struct pci_dev *pdev)
 static int ixgbe_poll(struct napi_struct *napi, int budget)
 {
 	struct ixgbe_q_vector *q_vector = container_of(napi,
-					  struct ixgbe_q_vector, napi);
+	                                          struct ixgbe_q_vector, napi);
 	struct ixgbe_adapter *adapter = q_vector->adapter;
 	int tx_cleaned, work_done = 0;
 
@@ -2371,7 +2369,7 @@ static void ixgbe_set_num_queues(struct ixgbe_adapter *adapter)
 }
 
 static void ixgbe_acquire_msix_vectors(struct ixgbe_adapter *adapter,
-				       int vectors)
+                                       int vectors)
 {
 	int err, vector_threshold;
 
@@ -2390,7 +2388,7 @@ static void ixgbe_acquire_msix_vectors(struct ixgbe_adapter *adapter,
 	 */
 	while (vectors >= vector_threshold) {
 		err = pci_enable_msix(adapter->pdev, adapter->msix_entries,
-				      vectors);
+		                      vectors);
 		if (!err) /* Success in acquiring all requested vectors. */
 			break;
 		else if (err < 0)
@@ -2425,9 +2423,6 @@ static void ixgbe_acquire_msix_vectors(struct ixgbe_adapter *adapter,
  **/
 static void __devinit ixgbe_cache_ring_register(struct ixgbe_adapter *adapter)
 {
-	/* TODO: Remove all uses of the indices in the cases where multiple
-	 *       features are OR'd together, if the feature set makes sense.
-	 */
 	int feature_mask = 0, rss_i;
 	int i, txr_idx, rxr_idx;
 
@@ -2468,12 +2463,12 @@ static int __devinit ixgbe_alloc_queues(struct ixgbe_adapter *adapter)
 	int i;
 
 	adapter->tx_ring = kcalloc(adapter->num_tx_queues,
-				   sizeof(struct ixgbe_ring), GFP_KERNEL);
+	                           sizeof(struct ixgbe_ring), GFP_KERNEL);
 	if (!adapter->tx_ring)
 		goto err_tx_ring_allocation;
 
 	adapter->rx_ring = kcalloc(adapter->num_rx_queues,
-				   sizeof(struct ixgbe_ring), GFP_KERNEL);
+	                           sizeof(struct ixgbe_ring), GFP_KERNEL);
 	if (!adapter->rx_ring)
 		goto err_rx_ring_allocation;
 
@@ -2505,7 +2500,7 @@ err_tx_ring_allocation:
  * capabilities of the hardware and the kernel.
  **/
 static int __devinit ixgbe_set_interrupt_capability(struct ixgbe_adapter
-						    *adapter)
+                                                    *adapter)
 {
 	int err = 0;
 	int vector, v_budget;
@@ -2517,7 +2512,7 @@ static int __devinit ixgbe_set_interrupt_capability(struct ixgbe_adapter
 	 * (roughly) twice the number of vectors as there are CPU's.
 	 */
 	v_budget = min(adapter->num_rx_queues + adapter->num_tx_queues,
-		       (int)(num_online_cpus() * 2)) + NON_Q_VECTORS;
+	               (int)(num_online_cpus() * 2)) + NON_Q_VECTORS;
 
 	/*
 	 * At the same time, hardware can only support a maximum of
@@ -2531,7 +2526,7 @@ static int __devinit ixgbe_set_interrupt_capability(struct ixgbe_adapter
 	/* A failure in MSI-X entry allocation isn't fatal, but it does
 	 * mean we disable MSI-X capabilities of the adapter. */
 	adapter->msix_entries = kcalloc(v_budget,
-					sizeof(struct msix_entry), GFP_KERNEL);
+	                                sizeof(struct msix_entry), GFP_KERNEL);
 	if (!adapter->msix_entries) {
 		adapter->flags &= ~IXGBE_FLAG_RSS_ENABLED;
 		ixgbe_set_num_queues(adapter);
@@ -2540,7 +2535,7 @@ static int __devinit ixgbe_set_interrupt_capability(struct ixgbe_adapter
 		err = ixgbe_alloc_queues(adapter);
 		if (err) {
 			DPRINTK(PROBE, ERR, "Unable to allocate memory "
-					    "for queues\n");
+			        "for queues\n");
 			goto out;
 		}
 
@@ -2561,7 +2556,7 @@ try_msi:
 		adapter->flags |= IXGBE_FLAG_MSI_ENABLED;
 	} else {
 		DPRINTK(HW, DEBUG, "Unable to allocate MSI interrupt, "
-				   "falling back to legacy.  Error: %d\n", err);
+		        "falling back to legacy.  Error: %d\n", err);
 		/* reset err */
 		err = 0;
 	}
@@ -2617,9 +2612,9 @@ static int __devinit ixgbe_init_interrupt_scheme(struct ixgbe_adapter *adapter)
 	}
 
 	DPRINTK(DRV, INFO, "Multiqueue %s: Rx Queue count = %u, "
-			   "Tx Queue count = %u\n",
-		(adapter->num_rx_queues > 1) ? "Enabled" :
-		"Disabled", adapter->num_rx_queues, adapter->num_tx_queues);
+	        "Tx Queue count = %u\n",
+	        (adapter->num_rx_queues > 1) ? "Enabled" :
+	        "Disabled", adapter->num_rx_queues, adapter->num_tx_queues);
 
 	set_bit(__IXGBE_DOWN, &adapter->state);
 
@@ -2746,7 +2741,7 @@ err:
  * Returns 0 on success, negative on failure
  **/
 int ixgbe_setup_rx_resources(struct ixgbe_adapter *adapter,
-			     struct ixgbe_ring *rx_ring)
+                             struct ixgbe_ring *rx_ring)
 {
 	struct pci_dev *pdev = adapter->pdev;
 	int size;
@@ -2761,7 +2756,7 @@ int ixgbe_setup_rx_resources(struct ixgbe_adapter *adapter,
 	rx_ring->rx_buffer_info = vmalloc(size);
 	if (!rx_ring->rx_buffer_info) {
 		DPRINTK(PROBE, ERR,
-			"vmalloc allocation failed for the rx desc ring\n");
+		        "vmalloc allocation failed for the rx desc ring\n");
 		goto alloc_failed;
 	}
 	memset(rx_ring->rx_buffer_info, 0, size);
@@ -2774,7 +2769,7 @@ int ixgbe_setup_rx_resources(struct ixgbe_adapter *adapter,
 
 	if (!rx_ring->desc) {
 		DPRINTK(PROBE, ERR,
-			"Memory allocation failed for the rx desc ring\n");
+		        "Memory allocation failed for the rx desc ring\n");
 		vfree(rx_ring->rx_buffer_info);
 		goto alloc_failed;
 	}
@@ -2827,7 +2822,7 @@ static void ixgbe_free_all_tx_resources(struct ixgbe_adapter *adapter)
 }
 
 /**
- * ixgbe_ree_rx_resources - Free Rx Resources
+ * ixgbe_free_rx_resources - Free Rx Resources
  * @adapter: board private structure
  * @rx_ring: ring to clean the resources from
  *
@@ -2881,11 +2876,10 @@ static int ixgbe_setup_all_tx_resources(struct ixgbe_adapter *adapter)
 
 	for (i = 0; i < adapter->num_tx_queues; i++) {
 		err = ixgbe_setup_tx_resources(adapter, &adapter->tx_ring[i]);
-		if (err) {
-			DPRINTK(PROBE, ERR,
-				"Allocation for Tx Queue %u failed\n", i);
-			break;
-		}
+		if (!err)
+			continue;
+		DPRINTK(PROBE, ERR, "Allocation for Tx Queue %u failed\n", i);
+		break;
 	}
 
 	return err;
@@ -2908,11 +2902,10 @@ static int ixgbe_setup_all_rx_resources(struct ixgbe_adapter *adapter)
 
 	for (i = 0; i < adapter->num_rx_queues; i++) {
 		err = ixgbe_setup_rx_resources(adapter, &adapter->rx_ring[i]);
-		if (err) {
-			DPRINTK(PROBE, ERR,
-				"Allocation for Rx Queue %u failed\n", i);
-			break;
-		}
+		if (!err)
+			continue;
+		DPRINTK(PROBE, ERR, "Allocation for Rx Queue %u failed\n", i);
+		break;
 	}
 
 	return err;
@@ -2935,7 +2928,7 @@ static int ixgbe_change_mtu(struct net_device *netdev, int new_mtu)
 		return -EINVAL;
 
 	DPRINTK(PROBE, INFO, "changing MTU from %d to %d\n",
-		netdev->mtu, new_mtu);
+	        netdev->mtu, new_mtu);
 	/* must set new MTU before calling down or up */
 	netdev->mtu = new_mtu;
 
@@ -3102,7 +3095,7 @@ void ixgbe_update_stats(struct ixgbe_adapter *adapter)
 
 	/* Rx Errors */
 	adapter->net_stats.rx_errors = adapter->stats.crcerrs +
-						adapter->stats.rlec;
+	                               adapter->stats.rlec;
 	adapter->net_stats.rx_dropped = 0;
 	adapter->net_stats.rx_length_errors = adapter->stats.rlec;
 	adapter->net_stats.rx_crc_errors = adapter->stats.crcerrs;
@@ -3206,8 +3199,8 @@ static void ixgbe_watchdog_task(struct work_struct *work)
 }
 
 static int ixgbe_tso(struct ixgbe_adapter *adapter,
-			 struct ixgbe_ring *tx_ring, struct sk_buff *skb,
-			 u32 tx_flags, u8 *hdr_len)
+                     struct ixgbe_ring *tx_ring, struct sk_buff *skb,
+                     u32 tx_flags, u8 *hdr_len)
 {
 	struct ixgbe_adv_tx_context_desc *context_desc;
 	unsigned int i;
@@ -3230,16 +3223,16 @@ static int ixgbe_tso(struct ixgbe_adapter *adapter,
 			iph->tot_len = 0;
 			iph->check = 0;
 			tcp_hdr(skb)->check = ~csum_tcpudp_magic(iph->saddr,
-								 iph->daddr, 0,
-								 IPPROTO_TCP,
-								 0);
+			                                         iph->daddr, 0,
+			                                         IPPROTO_TCP,
+			                                         0);
 			adapter->hw_tso_ctxt++;
 		} else if (skb_shinfo(skb)->gso_type == SKB_GSO_TCPV6) {
 			ipv6_hdr(skb)->payload_len = 0;
 			tcp_hdr(skb)->check =
 			    ~csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
-					     &ipv6_hdr(skb)->daddr,
-					     0, IPPROTO_TCP, 0);
+			                     &ipv6_hdr(skb)->daddr,
+			                     0, IPPROTO_TCP, 0);
 			adapter->hw_tso6_ctxt++;
 		}
 
@@ -3253,7 +3246,7 @@ static int ixgbe_tso(struct ixgbe_adapter *adapter,
 			vlan_macip_lens |=
 			    (tx_flags & IXGBE_TX_FLAGS_VLAN_MASK);
 		vlan_macip_lens |= ((skb_network_offset(skb)) <<
-				    IXGBE_ADVTXD_MACLEN_SHIFT);
+		                    IXGBE_ADVTXD_MACLEN_SHIFT);
 		*hdr_len += skb_network_offset(skb);
 		vlan_macip_lens |=
 		    (skb_transport_header(skb) - skb_network_header(skb));
@@ -3264,7 +3257,7 @@ static int ixgbe_tso(struct ixgbe_adapter *adapter,
 
 		/* ADV DTYP TUCMD MKRLOC/ISCSIHEDLEN */
 		type_tucmd_mlhl = (IXGBE_TXD_CMD_DEXT |
-				    IXGBE_ADVTXD_DTYP_CTXT);
+		                   IXGBE_ADVTXD_DTYP_CTXT);
 
 		if (skb->protocol == htons(ETH_P_IP))
 			type_tucmd_mlhl |= IXGBE_ADVTXD_TUCMD_IPV4;
@@ -3293,8 +3286,8 @@ static int ixgbe_tso(struct ixgbe_adapter *adapter,
 }
 
 static bool ixgbe_tx_csum(struct ixgbe_adapter *adapter,
-				   struct ixgbe_ring *tx_ring,
-				   struct sk_buff *skb, u32 tx_flags)
+                          struct ixgbe_ring *tx_ring,
+                          struct sk_buff *skb, u32 tx_flags)
 {
 	struct ixgbe_adv_tx_context_desc *context_desc;
 	unsigned int i;
@@ -3311,16 +3304,16 @@ static bool ixgbe_tx_csum(struct ixgbe_adapter *adapter,
 			vlan_macip_lens |=
 			    (tx_flags & IXGBE_TX_FLAGS_VLAN_MASK);
 		vlan_macip_lens |= (skb_network_offset(skb) <<
-				    IXGBE_ADVTXD_MACLEN_SHIFT);
+		                    IXGBE_ADVTXD_MACLEN_SHIFT);
 		if (skb->ip_summed == CHECKSUM_PARTIAL)
 			vlan_macip_lens |= (skb_transport_header(skb) -
-					    skb_network_header(skb));
+			                    skb_network_header(skb));
 
 		context_desc->vlan_macip_lens = cpu_to_le32(vlan_macip_lens);
 		context_desc->seqnum_seed = 0;
 
 		type_tucmd_mlhl |= (IXGBE_TXD_CMD_DEXT |
-				    IXGBE_ADVTXD_DTYP_CTXT);
+		                    IXGBE_ADVTXD_DTYP_CTXT);
 
 		if (skb->ip_summed == CHECKSUM_PARTIAL) {
 			switch (skb->protocol) {
@@ -3328,13 +3321,13 @@ static bool ixgbe_tx_csum(struct ixgbe_adapter *adapter,
 				type_tucmd_mlhl |= IXGBE_ADVTXD_TUCMD_IPV4;
 				if (ip_hdr(skb)->protocol == IPPROTO_TCP)
 					type_tucmd_mlhl |=
-						IXGBE_ADVTXD_TUCMD_L4T_TCP;
+					        IXGBE_ADVTXD_TUCMD_L4T_TCP;
 				break;
 			case __constant_htons(ETH_P_IPV6):
 				/* XXX what about other V6 headers?? */
 				if (ipv6_hdr(skb)->nexthdr == IPPROTO_TCP)
 					type_tucmd_mlhl |=
-						IXGBE_ADVTXD_TUCMD_L4T_TCP;
+					        IXGBE_ADVTXD_TUCMD_L4T_TCP;
 				break;
 			default:
 				if (unlikely(net_ratelimit())) {
@@ -3366,8 +3359,8 @@ static bool ixgbe_tx_csum(struct ixgbe_adapter *adapter,
 }
 
 static int ixgbe_tx_map(struct ixgbe_adapter *adapter,
-			struct ixgbe_ring *tx_ring,
-			struct sk_buff *skb, unsigned int first)
+                        struct ixgbe_ring *tx_ring,
+                        struct sk_buff *skb, unsigned int first)
 {
 	struct ixgbe_tx_buffer *tx_buffer_info;
 	unsigned int len = skb->len;
@@ -3385,8 +3378,8 @@ static int ixgbe_tx_map(struct ixgbe_adapter *adapter,
 
 		tx_buffer_info->length = size;
 		tx_buffer_info->dma = pci_map_single(adapter->pdev,
-						  skb->data + offset,
-						  size, PCI_DMA_TODEVICE);
+		                                     skb->data + offset,
+		                                     size, PCI_DMA_TODEVICE);
 		tx_buffer_info->time_stamp = jiffies;
 		tx_buffer_info->next_to_watch = i;
 
@@ -3411,9 +3404,10 @@ static int ixgbe_tx_map(struct ixgbe_adapter *adapter,
 
 			tx_buffer_info->length = size;
 			tx_buffer_info->dma = pci_map_page(adapter->pdev,
-							frag->page,
-							offset,
-							size, PCI_DMA_TODEVICE);
+			                                   frag->page,
+			                                   offset,
+			                                   size,
+			                                   PCI_DMA_TODEVICE);
 			tx_buffer_info->time_stamp = jiffies;
 			tx_buffer_info->next_to_watch = i;
 
@@ -3436,8 +3430,8 @@ static int ixgbe_tx_map(struct ixgbe_adapter *adapter,
 }
 
 static void ixgbe_tx_queue(struct ixgbe_adapter *adapter,
-			       struct ixgbe_ring *tx_ring,
-			       int tx_flags, int count, u32 paylen, u8 hdr_len)
+                           struct ixgbe_ring *tx_ring,
+                           int tx_flags, int count, u32 paylen, u8 hdr_len)
 {
 	union ixgbe_adv_tx_desc *tx_desc = NULL;
 	struct ixgbe_tx_buffer *tx_buffer_info;
@@ -3456,17 +3450,17 @@ static void ixgbe_tx_queue(struct ixgbe_adapter *adapter,
 		cmd_type_len |= IXGBE_ADVTXD_DCMD_TSE;
 
 		olinfo_status |= IXGBE_TXD_POPTS_TXSM <<
-						IXGBE_ADVTXD_POPTS_SHIFT;
+		                 IXGBE_ADVTXD_POPTS_SHIFT;
 
 		/* use index 1 context for tso */
 		olinfo_status |= (1 << IXGBE_ADVTXD_IDX_SHIFT);
 		if (tx_flags & IXGBE_TX_FLAGS_IPV4)
 			olinfo_status |= IXGBE_TXD_POPTS_IXSM <<
-						IXGBE_ADVTXD_POPTS_SHIFT;
+			                 IXGBE_ADVTXD_POPTS_SHIFT;
 
 	} else if (tx_flags & IXGBE_TX_FLAGS_CSUM)
 		olinfo_status |= IXGBE_TXD_POPTS_TXSM <<
-						IXGBE_ADVTXD_POPTS_SHIFT;
+		                 IXGBE_ADVTXD_POPTS_SHIFT;
 
 	olinfo_status |= ((paylen - hdr_len) << IXGBE_ADVTXD_PAYLEN_SHIFT);
 
@@ -3476,7 +3470,7 @@ static void ixgbe_tx_queue(struct ixgbe_adapter *adapter,
 		tx_desc = IXGBE_TX_DESC_ADV(*tx_ring, i);
 		tx_desc->read.buffer_addr = cpu_to_le64(tx_buffer_info->dma);
 		tx_desc->read.cmd_type_len =
-			cpu_to_le32(cmd_type_len | tx_buffer_info->length);
+		        cpu_to_le32(cmd_type_len | tx_buffer_info->length);
 		tx_desc->read.olinfo_status = cpu_to_le32(olinfo_status);
 
 		i++;
@@ -3499,7 +3493,7 @@ static void ixgbe_tx_queue(struct ixgbe_adapter *adapter,
 }
 
 static int __ixgbe_maybe_stop_tx(struct net_device *netdev,
-				 struct ixgbe_ring *tx_ring, int size)
+                                 struct ixgbe_ring *tx_ring, int size)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 
@@ -3521,7 +3515,7 @@ static int __ixgbe_maybe_stop_tx(struct net_device *netdev,
 }
 
 static int ixgbe_maybe_stop_tx(struct net_device *netdev,
-			       struct ixgbe_ring *tx_ring, int size)
+                              struct ixgbe_ring *tx_ring, int size)
 {
 	if (likely(IXGBE_DESC_UNUSED(tx_ring) >= size))
 		return 0;
@@ -3575,12 +3569,12 @@ static int ixgbe_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	if (tso)
 		tx_flags |= IXGBE_TX_FLAGS_TSO;
 	else if (ixgbe_tx_csum(adapter, tx_ring, skb, tx_flags) &&
-		 (skb->ip_summed == CHECKSUM_PARTIAL))
+	         (skb->ip_summed == CHECKSUM_PARTIAL))
 		tx_flags |= IXGBE_TX_FLAGS_CSUM;
 
 	ixgbe_tx_queue(adapter, tx_ring, tx_flags,
-			   ixgbe_tx_map(adapter, tx_ring, skb, first),
-			   skb->len, hdr_len);
+	               ixgbe_tx_map(adapter, tx_ring, skb, first),
+	               skb->len, hdr_len);
 
 	netdev->trans_start = jiffies;
 
@@ -3614,15 +3608,16 @@ static struct net_device_stats *ixgbe_get_stats(struct net_device *netdev)
 static int ixgbe_set_mac(struct net_device *netdev, void *p)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	struct ixgbe_hw *hw = &adapter->hw;
 	struct sockaddr *addr = p;
 
 	if (!is_valid_ether_addr(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
 	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
-	memcpy(adapter->hw.mac.addr, addr->sa_data, netdev->addr_len);
+	memcpy(hw->mac.addr, addr->sa_data, netdev->addr_len);
 
-	adapter->hw.mac.ops.set_rar(&adapter->hw, 0, adapter->hw.mac.addr, 0, IXGBE_RAH_AV);
+	hw->mac.ops.set_rar(hw, 0, hw->mac.addr, 0, IXGBE_RAH_AV);
 
 	return 0;
 }
@@ -3682,7 +3677,7 @@ static void ixgbe_napi_add_all(struct ixgbe_adapter *adapter)
 	for (i = 0; i < q_vectors; i++) {
 		struct ixgbe_q_vector *q_vector = &adapter->q_vector[i];
 		netif_napi_add(adapter->netdev, &q_vector->napi,
-			       (*poll), 64);
+		               (*poll), 64);
 	}
 }
 
@@ -3698,7 +3693,7 @@ static void ixgbe_napi_add_all(struct ixgbe_adapter *adapter)
  * and a hardware reset occur.
  **/
 static int __devinit ixgbe_probe(struct pci_dev *pdev,
-				 const struct pci_device_id *ent)
+                                 const struct pci_device_id *ent)
 {
 	struct net_device *netdev;
 	struct ixgbe_adapter *adapter = NULL;
@@ -3721,8 +3716,8 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 		if (err) {
 			err = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK);
 			if (err) {
-				dev_err(&pdev->dev, "No usable DMA configuration, "
-				          "aborting\n");
+				dev_err(&pdev->dev, "No usable DMA "
+				        "configuration, aborting\n");
 				goto err_dma;
 			}
 		}
@@ -3820,10 +3815,10 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	}
 
 	netdev->features = NETIF_F_SG |
-			   NETIF_F_IP_CSUM |
-			   NETIF_F_HW_VLAN_TX |
-			   NETIF_F_HW_VLAN_RX |
-			   NETIF_F_HW_VLAN_FILTER;
+	                   NETIF_F_IP_CSUM |
+	                   NETIF_F_HW_VLAN_TX |
+	                   NETIF_F_HW_VLAN_RX |
+	                   NETIF_F_HW_VLAN_FILTER;
 
 	netdev->features |= NETIF_F_IPV6_CSUM;
 	netdev->features |= NETIF_F_TSO;
@@ -3870,28 +3865,28 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	link_speed = link_status & IXGBE_PCI_LINK_SPEED;
 	link_width = link_status & IXGBE_PCI_LINK_WIDTH;
 	dev_info(&pdev->dev, "(PCI Express:%s:%s) "
-		 "%02x:%02x:%02x:%02x:%02x:%02x\n",
-		((link_speed == IXGBE_PCI_LINK_SPEED_5000) ? "5.0Gb/s" :
-		 (link_speed == IXGBE_PCI_LINK_SPEED_2500) ? "2.5Gb/s" :
-		 "Unknown"),
-		((link_width == IXGBE_PCI_LINK_WIDTH_8) ? "Width x8" :
-		 (link_width == IXGBE_PCI_LINK_WIDTH_4) ? "Width x4" :
-		 (link_width == IXGBE_PCI_LINK_WIDTH_2) ? "Width x2" :
-		 (link_width == IXGBE_PCI_LINK_WIDTH_1) ? "Width x1" :
-		 "Unknown"),
-		netdev->dev_addr[0], netdev->dev_addr[1], netdev->dev_addr[2],
-		netdev->dev_addr[3], netdev->dev_addr[4], netdev->dev_addr[5]);
+	         "%02x:%02x:%02x:%02x:%02x:%02x\n",
+	        ((link_speed == IXGBE_PCI_LINK_SPEED_5000) ? "5.0Gb/s" :
+	         (link_speed == IXGBE_PCI_LINK_SPEED_2500) ? "2.5Gb/s" :
+	         "Unknown"),
+	        ((link_width == IXGBE_PCI_LINK_WIDTH_8) ? "Width x8" :
+	         (link_width == IXGBE_PCI_LINK_WIDTH_4) ? "Width x4" :
+	         (link_width == IXGBE_PCI_LINK_WIDTH_2) ? "Width x2" :
+	         (link_width == IXGBE_PCI_LINK_WIDTH_1) ? "Width x1" :
+	         "Unknown"),
+	        netdev->dev_addr[0], netdev->dev_addr[1], netdev->dev_addr[2],
+	        netdev->dev_addr[3], netdev->dev_addr[4], netdev->dev_addr[5]);
 	ixgbe_read_pba_num_generic(hw, &part_num);
 	dev_info(&pdev->dev, "MAC: %d, PHY: %d, PBA No: %06x-%03x\n",
-		 hw->mac.type, hw->phy.type,
-		 (part_num >> 8), (part_num & 0xff));
+	         hw->mac.type, hw->phy.type,
+	         (part_num >> 8), (part_num & 0xff));
 
 	if (link_width <= IXGBE_PCI_LINK_WIDTH_4) {
 		dev_warn(&pdev->dev, "PCI-Express bandwidth available for "
-			 "this card is not sufficient for optimal "
-			 "performance.\n");
+		         "this card is not sufficient for optimal "
+		         "performance.\n");
 		dev_warn(&pdev->dev, "For optimal performance a x8 "
-			 "PCI-Express slot is required.\n");
+		         "PCI-Express slot is required.\n");
 	}
 
 	/* reset the hardware with the new settings */
@@ -3999,7 +3994,7 @@ static void __devexit ixgbe_remove(struct pci_dev *pdev)
  * this device has been detected.
  */
 static pci_ers_result_t ixgbe_io_error_detected(struct pci_dev *pdev,
-						pci_channel_state_t state)
+                                                pci_channel_state_t state)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct ixgbe_adapter *adapter = netdev->priv;
@@ -4010,7 +4005,7 @@ static pci_ers_result_t ixgbe_io_error_detected(struct pci_dev *pdev,
 		ixgbe_down(adapter);
 	pci_disable_device(pdev);
 
-	/* Request a slot slot reset. */
+	/* Request a slot reset. */
 	return PCI_ERS_RESULT_NEED_RESET;
 }
 
@@ -4027,7 +4022,7 @@ static pci_ers_result_t ixgbe_io_slot_reset(struct pci_dev *pdev)
 
 	if (pci_enable_device(pdev)) {
 		DPRINTK(PROBE, ERR,
-			"Cannot re-enable PCI device after reset.\n");
+		        "Cannot re-enable PCI device after reset.\n");
 		return PCI_ERS_RESULT_DISCONNECT;
 	}
 	pci_set_master(pdev);
@@ -4104,6 +4099,7 @@ static int __init ixgbe_init_module(void)
 	ret = pci_register_driver(&ixgbe_driver);
 	return ret;
 }
+
 module_init(ixgbe_init_module);
 
 /**
@@ -4122,12 +4118,12 @@ static void __exit ixgbe_exit_module(void)
 
 #if defined(CONFIG_DCA) || defined(CONFIG_DCA_MODULE)
 static int ixgbe_notify_dca(struct notifier_block *nb, unsigned long event,
-			    void *p)
+                            void *p)
 {
 	int ret_val;
 
 	ret_val = driver_for_each_device(&ixgbe_driver.driver, NULL, &event,
-					 __ixgbe_notify_dca);
+	                                 __ixgbe_notify_dca);
 
 	return ret_val ? NOTIFY_BAD : NOTIFY_DONE;
 }
diff --git a/drivers/net/ixgbe/ixgbe_phy.c b/drivers/net/ixgbe/ixgbe_phy.c
index 63a7017..764035a 100644
--- a/drivers/net/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ixgbe/ixgbe_phy.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2007 Intel Corporation.
+  Copyright(c) 1999 - 2008 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -20,7 +20,6 @@
   the file called "COPYING".
 
   Contact Information:
-  Linux NICS <linux.nics@intel.com>
   e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
   Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
 
diff --git a/drivers/net/ixgbe/ixgbe_phy.h b/drivers/net/ixgbe/ixgbe_phy.h
index f88c913..9bfe3f2 100644
--- a/drivers/net/ixgbe/ixgbe_phy.h
+++ b/drivers/net/ixgbe/ixgbe_phy.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2007 Intel Corporation.
+  Copyright(c) 1999 - 2008 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -20,7 +20,6 @@
   the file called "COPYING".
 
   Contact Information:
-  Linux NICS <linux.nics@intel.com>
   e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
   Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
 
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index c76e30b..c6f8fa1 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2007 Intel Corporation.
+  Copyright(c) 1999 - 2008 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -20,7 +20,6 @@
   the file called "COPYING".
 
   Contact Information:
-  Linux NICS <linux.nics@intel.com>
   e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
   Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
 

