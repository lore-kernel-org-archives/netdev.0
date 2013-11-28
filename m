From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 8/8] ixgbe: Make ixgbe_identify_qsfp_module_generic static
Date: Wed, 27 Nov 2013 23:36:02 -0800
Message-ID: <1385624162-10116-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1385624162-10116-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:62417 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754620Ab3K1Hgg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Nov 2013 02:36:36 -0500
In-Reply-To: <1385624162-10116-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

Correct a namespace complaint by making the function static
and moving the prototype into the .c file.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c | 3 ++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h | 1 -
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
index e4c6760..39217e5 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
@@ -46,6 +46,7 @@ static bool ixgbe_get_i2c_data(u32 *i2cctl);
 static void ixgbe_i2c_bus_clear(struct ixgbe_hw *hw);
 static enum ixgbe_phy_type ixgbe_get_phy_type_from_id(u32 phy_id);
 static s32 ixgbe_get_phy_id(struct ixgbe_hw *hw);
+static s32 ixgbe_identify_qsfp_module_generic(struct ixgbe_hw *hw);
 
 /**
  *  ixgbe_identify_phy_generic - Get physical layer module
@@ -1164,7 +1165,7 @@ err_read_i2c_eeprom:
  *
  * Searches for and identifies the QSFP module and assigns appropriate PHY type
  **/
-s32 ixgbe_identify_qsfp_module_generic(struct ixgbe_hw *hw)
+static s32 ixgbe_identify_qsfp_module_generic(struct ixgbe_hw *hw)
 {
 	struct ixgbe_adapter *adapter = hw->back;
 	s32 status = IXGBE_ERR_PHY_ADDR_INVALID;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h
index aae900a..fffcbdd 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h
@@ -145,7 +145,6 @@ s32 ixgbe_get_phy_firmware_version_generic(struct ixgbe_hw *hw,
 s32 ixgbe_reset_phy_nl(struct ixgbe_hw *hw);
 s32 ixgbe_identify_module_generic(struct ixgbe_hw *hw);
 s32 ixgbe_identify_sfp_module_generic(struct ixgbe_hw *hw);
-s32 ixgbe_identify_qsfp_module_generic(struct ixgbe_hw *hw);
 s32 ixgbe_get_sfp_init_sequence_offsets(struct ixgbe_hw *hw,
                                         u16 *list_offset,
                                         u16 *data_offset);
-- 
1.8.3.1
