From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/11] e1000e: make function tables const
Date: Thu, 29 Sep 2011 22:24:41 -0700
Message-ID: <1317360291-5576-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1317360291-5576-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:56204 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753808Ab1I3FYz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Sep 2011 01:24:55 -0400
In-Reply-To: <1317360291-5576-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The initial function and setup tables can be marked as constant.

Reported-by: Stephen Hemminger <shemminger@vyatta.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/e1000e/80003es2lan.c |    8 +++---
 drivers/net/ethernet/intel/e1000e/82571.c       |   20 ++++++++--------
 drivers/net/ethernet/intel/e1000e/e1000.h       |   28 +++++++++++-----------
 drivers/net/ethernet/intel/e1000e/ich8lan.c     |   16 ++++++------
 4 files changed, 36 insertions(+), 36 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/80003es2lan.c b/drivers/net/ethernet/intel/e1000e/80003es2lan.c
index b754433..e1159e5 100644
--- a/drivers/net/ethernet/intel/e1000e/80003es2lan.c
+++ b/drivers/net/ethernet/intel/e1000e/80003es2lan.c
@@ -1441,7 +1441,7 @@ static void e1000_clear_hw_cntrs_80003es2lan(struct e1000_hw *hw)
 	er32(ICRXDMTC);
 }
 
-static struct e1000_mac_operations es2_mac_ops = {
+static const struct e1000_mac_operations es2_mac_ops = {
 	.read_mac_addr		= e1000_read_mac_addr_80003es2lan,
 	.id_led_init		= e1000e_id_led_init,
 	.blink_led		= e1000e_blink_led_generic,
@@ -1464,7 +1464,7 @@ static struct e1000_mac_operations es2_mac_ops = {
 	.setup_led		= e1000e_setup_led_generic,
 };
 
-static struct e1000_phy_operations es2_phy_ops = {
+static const struct e1000_phy_operations es2_phy_ops = {
 	.acquire		= e1000_acquire_phy_80003es2lan,
 	.check_polarity		= e1000_check_polarity_m88,
 	.check_reset_block	= e1000e_check_reset_block_generic,
@@ -1482,7 +1482,7 @@ static struct e1000_phy_operations es2_phy_ops = {
 	.cfg_on_link_up      	= e1000_cfg_on_link_up_80003es2lan,
 };
 
-static struct e1000_nvm_operations es2_nvm_ops = {
+static const struct e1000_nvm_operations es2_nvm_ops = {
 	.acquire		= e1000_acquire_nvm_80003es2lan,
 	.read			= e1000e_read_nvm_eerd,
 	.release		= e1000_release_nvm_80003es2lan,
@@ -1492,7 +1492,7 @@ static struct e1000_nvm_operations es2_nvm_ops = {
 	.write			= e1000_write_nvm_80003es2lan,
 };
 
-struct e1000_info e1000_es2_info = {
+const struct e1000_info e1000_es2_info = {
 	.mac			= e1000_80003es2lan,
 	.flags			= FLAG_HAS_HW_VLAN_FILTER
 				  | FLAG_HAS_JUMBO_FRAMES
diff --git a/drivers/net/ethernet/intel/e1000e/82571.c b/drivers/net/ethernet/intel/e1000e/82571.c
index 2d4dc53..a3e65fd 100644
--- a/drivers/net/ethernet/intel/e1000e/82571.c
+++ b/drivers/net/ethernet/intel/e1000e/82571.c
@@ -1927,7 +1927,7 @@ static void e1000_clear_hw_cntrs_82571(struct e1000_hw *hw)
 	er32(ICRXDMTC);
 }
 
-static struct e1000_mac_operations e82571_mac_ops = {
+static const struct e1000_mac_operations e82571_mac_ops = {
 	/* .check_mng_mode: mac type dependent */
 	/* .check_for_link: media type dependent */
 	.id_led_init		= e1000e_id_led_init,
@@ -1949,7 +1949,7 @@ static struct e1000_mac_operations e82571_mac_ops = {
 	.read_mac_addr		= e1000_read_mac_addr_82571,
 };
 
-static struct e1000_phy_operations e82_phy_ops_igp = {
+static const struct e1000_phy_operations e82_phy_ops_igp = {
 	.acquire		= e1000_get_hw_semaphore_82571,
 	.check_polarity		= e1000_check_polarity_igp,
 	.check_reset_block	= e1000e_check_reset_block_generic,
@@ -1967,7 +1967,7 @@ static struct e1000_phy_operations e82_phy_ops_igp = {
 	.cfg_on_link_up      	= NULL,
 };
 
-static struct e1000_phy_operations e82_phy_ops_m88 = {
+static const struct e1000_phy_operations e82_phy_ops_m88 = {
 	.acquire		= e1000_get_hw_semaphore_82571,
 	.check_polarity		= e1000_check_polarity_m88,
 	.check_reset_block	= e1000e_check_reset_block_generic,
@@ -1985,7 +1985,7 @@ static struct e1000_phy_operations e82_phy_ops_m88 = {
 	.cfg_on_link_up      	= NULL,
 };
 
-static struct e1000_phy_operations e82_phy_ops_bm = {
+static const struct e1000_phy_operations e82_phy_ops_bm = {
 	.acquire		= e1000_get_hw_semaphore_82571,
 	.check_polarity		= e1000_check_polarity_m88,
 	.check_reset_block	= e1000e_check_reset_block_generic,
@@ -2003,7 +2003,7 @@ static struct e1000_phy_operations e82_phy_ops_bm = {
 	.cfg_on_link_up      	= NULL,
 };
 
-static struct e1000_nvm_operations e82571_nvm_ops = {
+static const struct e1000_nvm_operations e82571_nvm_ops = {
 	.acquire		= e1000_acquire_nvm_82571,
 	.read			= e1000e_read_nvm_eerd,
 	.release		= e1000_release_nvm_82571,
@@ -2013,7 +2013,7 @@ static struct e1000_nvm_operations e82571_nvm_ops = {
 	.write			= e1000_write_nvm_82571,
 };
 
-struct e1000_info e1000_82571_info = {
+const struct e1000_info e1000_82571_info = {
 	.mac			= e1000_82571,
 	.flags			= FLAG_HAS_HW_VLAN_FILTER
 				  | FLAG_HAS_JUMBO_FRAMES
@@ -2034,7 +2034,7 @@ struct e1000_info e1000_82571_info = {
 	.nvm_ops		= &e82571_nvm_ops,
 };
 
-struct e1000_info e1000_82572_info = {
+const struct e1000_info e1000_82572_info = {
 	.mac			= e1000_82572,
 	.flags			= FLAG_HAS_HW_VLAN_FILTER
 				  | FLAG_HAS_JUMBO_FRAMES
@@ -2052,7 +2052,7 @@ struct e1000_info e1000_82572_info = {
 	.nvm_ops		= &e82571_nvm_ops,
 };
 
-struct e1000_info e1000_82573_info = {
+const struct e1000_info e1000_82573_info = {
 	.mac			= e1000_82573,
 	.flags			= FLAG_HAS_HW_VLAN_FILTER
 				  | FLAG_HAS_WOL
@@ -2070,7 +2070,7 @@ struct e1000_info e1000_82573_info = {
 	.nvm_ops		= &e82571_nvm_ops,
 };
 
-struct e1000_info e1000_82574_info = {
+const struct e1000_info e1000_82574_info = {
 	.mac			= e1000_82574,
 	.flags			= FLAG_HAS_HW_VLAN_FILTER
 				  | FLAG_HAS_MSIX
@@ -2091,7 +2091,7 @@ struct e1000_info e1000_82574_info = {
 	.nvm_ops		= &e82571_nvm_ops,
 };
 
-struct e1000_info e1000_82583_info = {
+const struct e1000_info e1000_82583_info = {
 	.mac			= e1000_82583,
 	.flags			= FLAG_HAS_HW_VLAN_FILTER
 				  | FLAG_HAS_WOL
diff --git a/drivers/net/ethernet/intel/e1000e/e1000.h b/drivers/net/ethernet/intel/e1000e/e1000.h
index 1b15d1f..7877b9c 100644
--- a/drivers/net/ethernet/intel/e1000e/e1000.h
+++ b/drivers/net/ethernet/intel/e1000e/e1000.h
@@ -406,9 +406,9 @@ struct e1000_info {
 	u32			pba;
 	u32			max_hw_frame_size;
 	s32			(*get_variants)(struct e1000_adapter *);
-	struct e1000_mac_operations *mac_ops;
-	struct e1000_phy_operations *phy_ops;
-	struct e1000_nvm_operations *nvm_ops;
+	const struct e1000_mac_operations *mac_ops;
+	const struct e1000_phy_operations *phy_ops;
+	const struct e1000_nvm_operations *nvm_ops;
 };
 
 /* hardware capability, feature, and workaround flags */
@@ -506,17 +506,17 @@ extern unsigned int copybreak;
 
 extern char *e1000e_get_hw_dev_name(struct e1000_hw *hw);
 
-extern struct e1000_info e1000_82571_info;
-extern struct e1000_info e1000_82572_info;
-extern struct e1000_info e1000_82573_info;
-extern struct e1000_info e1000_82574_info;
-extern struct e1000_info e1000_82583_info;
-extern struct e1000_info e1000_ich8_info;
-extern struct e1000_info e1000_ich9_info;
-extern struct e1000_info e1000_ich10_info;
-extern struct e1000_info e1000_pch_info;
-extern struct e1000_info e1000_pch2_info;
-extern struct e1000_info e1000_es2_info;
+extern const struct e1000_info e1000_82571_info;
+extern const struct e1000_info e1000_82572_info;
+extern const struct e1000_info e1000_82573_info;
+extern const struct e1000_info e1000_82574_info;
+extern const struct e1000_info e1000_82583_info;
+extern const struct e1000_info e1000_ich8_info;
+extern const struct e1000_info e1000_ich9_info;
+extern const struct e1000_info e1000_ich10_info;
+extern const struct e1000_info e1000_pch_info;
+extern const struct e1000_info e1000_pch2_info;
+extern const struct e1000_info e1000_es2_info;
 
 extern s32 e1000_read_pba_string_generic(struct e1000_hw *hw, u8 *pba_num,
 					 u32 pba_num_size);
diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index 3fc3acc..3b063e1 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -4011,7 +4011,7 @@ release:
 	}
 }
 
-static struct e1000_mac_operations ich8_mac_ops = {
+static const struct e1000_mac_operations ich8_mac_ops = {
 	.id_led_init		= e1000e_id_led_init,
 	/* check_mng_mode dependent on mac type */
 	.check_for_link		= e1000_check_for_copper_link_ich8lan,
@@ -4030,7 +4030,7 @@ static struct e1000_mac_operations ich8_mac_ops = {
 	/* id_led_init dependent on mac type */
 };
 
-static struct e1000_phy_operations ich8_phy_ops = {
+static const struct e1000_phy_operations ich8_phy_ops = {
 	.acquire		= e1000_acquire_swflag_ich8lan,
 	.check_reset_block	= e1000_check_reset_block_ich8lan,
 	.commit			= NULL,
@@ -4044,7 +4044,7 @@ static struct e1000_phy_operations ich8_phy_ops = {
 	.write_reg		= e1000e_write_phy_reg_igp,
 };
 
-static struct e1000_nvm_operations ich8_nvm_ops = {
+static const struct e1000_nvm_operations ich8_nvm_ops = {
 	.acquire		= e1000_acquire_nvm_ich8lan,
 	.read		 	= e1000_read_nvm_ich8lan,
 	.release		= e1000_release_nvm_ich8lan,
@@ -4054,7 +4054,7 @@ static struct e1000_nvm_operations ich8_nvm_ops = {
 	.write			= e1000_write_nvm_ich8lan,
 };
 
-struct e1000_info e1000_ich8_info = {
+const struct e1000_info e1000_ich8_info = {
 	.mac			= e1000_ich8lan,
 	.flags			= FLAG_HAS_WOL
 				  | FLAG_IS_ICH
@@ -4070,7 +4070,7 @@ struct e1000_info e1000_ich8_info = {
 	.nvm_ops		= &ich8_nvm_ops,
 };
 
-struct e1000_info e1000_ich9_info = {
+const struct e1000_info e1000_ich9_info = {
 	.mac			= e1000_ich9lan,
 	.flags			= FLAG_HAS_JUMBO_FRAMES
 				  | FLAG_IS_ICH
@@ -4088,7 +4088,7 @@ struct e1000_info e1000_ich9_info = {
 	.nvm_ops		= &ich8_nvm_ops,
 };
 
-struct e1000_info e1000_ich10_info = {
+const struct e1000_info e1000_ich10_info = {
 	.mac			= e1000_ich10lan,
 	.flags			= FLAG_HAS_JUMBO_FRAMES
 				  | FLAG_IS_ICH
@@ -4106,7 +4106,7 @@ struct e1000_info e1000_ich10_info = {
 	.nvm_ops		= &ich8_nvm_ops,
 };
 
-struct e1000_info e1000_pch_info = {
+const struct e1000_info e1000_pch_info = {
 	.mac			= e1000_pchlan,
 	.flags			= FLAG_IS_ICH
 				  | FLAG_HAS_WOL
@@ -4125,7 +4125,7 @@ struct e1000_info e1000_pch_info = {
 	.nvm_ops		= &ich8_nvm_ops,
 };
 
-struct e1000_info e1000_pch2_info = {
+const struct e1000_info e1000_pch2_info = {
 	.mac			= e1000_pch2lan,
 	.flags			= FLAG_IS_ICH
 				  | FLAG_HAS_WOL
-- 
1.7.6.2
