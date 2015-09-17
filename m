From: Janusz Wolak <januszvdm@gmail.com>
Subject: e1000_hw_c_checkpatch_coding_style_errors_remove
Date: Thu, 17 Sep 2015 23:56:48 +0200
Message-ID: <55FB3720.6010805@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030100060908010907050409"
To: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f181.google.com ([209.85.217.181]:35351 "EHLO
	mail-lb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751908AbbIQV4v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2015 17:56:51 -0400
Received: by lbpo4 with SMTP id o4so16391888lbp.2
        for <netdev@vger.kernel.org>; Thu, 17 Sep 2015 14:56:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030100060908010907050409
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit


--------------030100060908010907050409
Content-Type: text/x-patch;
 name="e1000_hw_c_Remove_checkpatch_coding_style_errors.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="e1000_hw_c_Remove_checkpatch_coding_style_errors.patch"

>From 4ac9fd87e092f58eb7a6ed898360dfd83c5c10f5 Mon Sep 17 00:00:00 2001
From: Janusz Wolak <januszvdm@gmail.com>
Date: Thu, 17 Sep 2015 23:34:29 +0200
Subject: [PATCH] Remove checkpatch coding style errors.

Signed-off-by: Janusz Wolak <januszvdm@gmail.com>
---
 drivers/net/ethernet/intel/e1000/e1000_hw.c | 16 +++++++---------
 1 file changed, 7 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_hw.c b/drivers/net/ethernet/intel/e1000/e1000_hw.c
index 45c8c864..cc1fe40 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_hw.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_hw.c
@@ -683,7 +683,7 @@ static s32 e1000_adjust_serdes_amplitude(struct e1000_hw *hw)
 	}
 
 	ret_val = e1000_read_eeprom(hw, EEPROM_SERDES_AMPLITUDE, 1,
-	                            &eeprom_data);
+				    &eeprom_data);
 	if (ret_val) {
 		return ret_val;
 	}
@@ -1652,7 +1652,7 @@ s32 e1000_phy_setup_autoneg(struct e1000_hw *hw)
 		mii_1000t_ctrl_reg = 0;
 	} else {
 		ret_val = e1000_write_phy_reg(hw, PHY_1000T_CTRL,
-		                              mii_1000t_ctrl_reg);
+					      mii_1000t_ctrl_reg);
 		if (ret_val)
 			return ret_val;
 	}
@@ -2193,8 +2193,7 @@ static s32 e1000_config_fc_after_link_up(struct e1000_hw *hw)
 			else if (!(mii_nway_adv_reg & NWAY_AR_PAUSE) &&
 				 (mii_nway_adv_reg & NWAY_AR_ASM_DIR) &&
 				 (mii_nway_lp_ability_reg & NWAY_LPAR_PAUSE) &&
-				 (mii_nway_lp_ability_reg & NWAY_LPAR_ASM_DIR))
-			{
+				 (mii_nway_lp_ability_reg & NWAY_LPAR_ASM_DIR)) {
 				hw->fc = E1000_FC_TX_PAUSE;
 				e_dbg
 				    ("Flow Control = TX PAUSE frames only.\n");
@@ -2210,8 +2209,7 @@ static s32 e1000_config_fc_after_link_up(struct e1000_hw *hw)
 			else if ((mii_nway_adv_reg & NWAY_AR_PAUSE) &&
 				 (mii_nway_adv_reg & NWAY_AR_ASM_DIR) &&
 				 !(mii_nway_lp_ability_reg & NWAY_LPAR_PAUSE) &&
-				 (mii_nway_lp_ability_reg & NWAY_LPAR_ASM_DIR))
-			{
+				 (mii_nway_lp_ability_reg & NWAY_LPAR_ASM_DIR)) {
 				hw->fc = E1000_FC_RX_PAUSE;
 				e_dbg
 				    ("Flow Control = RX PAUSE frames only.\n");
@@ -3449,7 +3447,7 @@ s32 e1000_phy_get_info(struct e1000_hw *hw, struct e1000_phy_info *phy_info)
 	if (hw->phy_type == e1000_phy_igp)
 		return e1000_phy_igp_get_info(hw, phy_info);
 	else if ((hw->phy_type == e1000_phy_8211) ||
-	         (hw->phy_type == e1000_phy_8201))
+		 (hw->phy_type == e1000_phy_8201))
 		return E1000_SUCCESS;
 	else
 		return e1000_phy_m88_get_info(hw, phy_info);
@@ -3896,7 +3894,7 @@ static s32 e1000_do_read_eeprom(struct e1000_hw *hw, u16 offset, u16 words,
 
 	if (hw->mac_type == e1000_ce4100) {
 		GBE_CONFIG_FLASH_READ(GBE_CONFIG_BASE_VIRT, offset, words,
-		                      data);
+				      data);
 		return E1000_SUCCESS;
 	}
 
@@ -4070,7 +4068,7 @@ static s32 e1000_do_write_eeprom(struct e1000_hw *hw, u16 offset, u16 words,
 
 	if (hw->mac_type == e1000_ce4100) {
 		GBE_CONFIG_FLASH_WRITE(GBE_CONFIG_BASE_VIRT, offset, words,
-		                       data);
+				       data);
 		return E1000_SUCCESS;
 	}
 
-- 
1.9.1


--------------030100060908010907050409--
