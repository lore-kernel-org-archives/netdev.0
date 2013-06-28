From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH v3 1/3] pch_gbe: remove inline keyword for exported functions
Date: Fri, 28 Jun 2013 14:02:52 +0300
Message-ID: <1372417374-28128-2-git-send-email-andriy.shevchenko@linux.intel.com>
References: <1372417374-28128-1-git-send-email-andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Darren Hart <dvhart@linux.intel.com>,
	Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:40881 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755640Ab3F1LDE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Jun 2013 07:03:04 -0400
In-Reply-To: <1372417374-28128-1-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no much sense to mark functions inline that are going to be used in
the other compile modules.

Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_api.c | 21 +++++++++++----------
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c    |  2 +-
 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.c |  3 +--
 3 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_api.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_api.c
index 5ae03e8..82e72b2 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_api.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_api.c
@@ -19,6 +19,7 @@
  */
 #include "pch_gbe.h"
 #include "pch_gbe_phy.h"
+#include "pch_gbe_api.h"
 
 /* bus type values */
 #define pch_gbe_bus_type_unknown	0
@@ -112,7 +113,7 @@ static void pch_gbe_plat_init_function_pointers(struct pch_gbe_hw *hw)
  *	0:	Successfully
  *	ENOSYS:	Function is not registered
  */
-inline s32 pch_gbe_hal_setup_init_funcs(struct pch_gbe_hw *hw)
+s32 pch_gbe_hal_setup_init_funcs(struct pch_gbe_hw *hw)
 {
 	if (!hw->reg) {
 		pr_err("ERROR: Registers not mapped\n");
@@ -126,7 +127,7 @@ inline s32 pch_gbe_hal_setup_init_funcs(struct pch_gbe_hw *hw)
  * pch_gbe_hal_get_bus_info - Obtain bus information for adapter
  * @hw:	Pointer to the HW structure
  */
-inline void pch_gbe_hal_get_bus_info(struct pch_gbe_hw *hw)
+void pch_gbe_hal_get_bus_info(struct pch_gbe_hw *hw)
 {
 	if (!hw->func->get_bus_info)
 		pr_err("ERROR: configuration\n");
@@ -141,7 +142,7 @@ inline void pch_gbe_hal_get_bus_info(struct pch_gbe_hw *hw)
  *	0:	Successfully
  *	ENOSYS:	Function is not registered
  */
-inline s32 pch_gbe_hal_init_hw(struct pch_gbe_hw *hw)
+s32 pch_gbe_hal_init_hw(struct pch_gbe_hw *hw)
 {
 	if (!hw->func->init_hw) {
 		pr_err("ERROR: configuration\n");
@@ -159,7 +160,7 @@ inline s32 pch_gbe_hal_init_hw(struct pch_gbe_hw *hw)
  *	0:	Successfully
  *	Negative value:	Failed
  */
-inline s32 pch_gbe_hal_read_phy_reg(struct pch_gbe_hw *hw, u32 offset,
+s32 pch_gbe_hal_read_phy_reg(struct pch_gbe_hw *hw, u32 offset,
 					u16 *data)
 {
 	if (!hw->func->read_phy_reg)
@@ -176,7 +177,7 @@ inline s32 pch_gbe_hal_read_phy_reg(struct pch_gbe_hw *hw, u32 offset,
  *	0:	Successfully
  *	Negative value:	Failed
  */
-inline s32 pch_gbe_hal_write_phy_reg(struct pch_gbe_hw *hw, u32 offset,
+s32 pch_gbe_hal_write_phy_reg(struct pch_gbe_hw *hw, u32 offset,
 					u16 data)
 {
 	if (!hw->func->write_phy_reg)
@@ -188,7 +189,7 @@ inline s32 pch_gbe_hal_write_phy_reg(struct pch_gbe_hw *hw, u32 offset,
  * pch_gbe_hal_phy_hw_reset - Hard PHY reset
  * @hw:	    Pointer to the HW structure
  */
-inline void pch_gbe_hal_phy_hw_reset(struct pch_gbe_hw *hw)
+void pch_gbe_hal_phy_hw_reset(struct pch_gbe_hw *hw)
 {
 	if (!hw->func->reset_phy)
 		pr_err("ERROR: configuration\n");
@@ -200,7 +201,7 @@ inline void pch_gbe_hal_phy_hw_reset(struct pch_gbe_hw *hw)
  * pch_gbe_hal_phy_sw_reset - Soft PHY reset
  * @hw:	    Pointer to the HW structure
  */
-inline void pch_gbe_hal_phy_sw_reset(struct pch_gbe_hw *hw)
+void pch_gbe_hal_phy_sw_reset(struct pch_gbe_hw *hw)
 {
 	if (!hw->func->sw_reset_phy)
 		pr_err("ERROR: configuration\n");
@@ -215,7 +216,7 @@ inline void pch_gbe_hal_phy_sw_reset(struct pch_gbe_hw *hw)
  *	0:	Successfully
  *	ENOSYS:	Function is not registered
  */
-inline s32 pch_gbe_hal_read_mac_addr(struct pch_gbe_hw *hw)
+s32 pch_gbe_hal_read_mac_addr(struct pch_gbe_hw *hw)
 {
 	if (!hw->func->read_mac_addr) {
 		pr_err("ERROR: configuration\n");
@@ -228,7 +229,7 @@ inline s32 pch_gbe_hal_read_mac_addr(struct pch_gbe_hw *hw)
  * pch_gbe_hal_power_up_phy - Power up PHY
  * @hw:	Pointer to the HW structure
  */
-inline void pch_gbe_hal_power_up_phy(struct pch_gbe_hw *hw)
+void pch_gbe_hal_power_up_phy(struct pch_gbe_hw *hw)
 {
 	if (hw->func->power_up_phy)
 		hw->func->power_up_phy(hw);
@@ -238,7 +239,7 @@ inline void pch_gbe_hal_power_up_phy(struct pch_gbe_hw *hw)
  * pch_gbe_hal_power_down_phy - Power down PHY
  * @hw:	Pointer to the HW structure
  */
-inline void pch_gbe_hal_power_down_phy(struct pch_gbe_hw *hw)
+void pch_gbe_hal_power_down_phy(struct pch_gbe_hw *hw)
 {
 	if (hw->func->power_down_phy)
 		hw->func->power_down_phy(hw);
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index 0c1c65a..16d5ffa 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -287,7 +287,7 @@ static int hwtstamp_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 	return copy_to_user(ifr->ifr_data, &cfg, sizeof(cfg)) ? -EFAULT : 0;
 }
 
-inline void pch_gbe_mac_load_mac_addr(struct pch_gbe_hw *hw)
+static inline void pch_gbe_mac_load_mac_addr(struct pch_gbe_hw *hw)
 {
 	iowrite32(0x01, &hw->reg->MAC_ADDR_LOAD);
 }
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.c
index 28bb960..b97c657 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.c
@@ -235,7 +235,7 @@ void pch_gbe_phy_power_down(struct pch_gbe_hw *hw)
  * pch_gbe_phy_set_rgmii - RGMII interface setting
  * @hw:	            Pointer to the HW structure
  */
-inline void pch_gbe_phy_set_rgmii(struct pch_gbe_hw *hw)
+void pch_gbe_phy_set_rgmii(struct pch_gbe_hw *hw)
 {
 	pch_gbe_phy_sw_reset(hw);
 }
@@ -270,5 +270,4 @@ void pch_gbe_phy_init_setting(struct pch_gbe_hw *hw)
 	pch_gbe_phy_read_reg_miic(hw, PHY_PHYSP_CONTROL, &mii_reg);
 	mii_reg |= PHYSP_CTRL_ASSERT_CRS_TX;
 	pch_gbe_phy_write_reg_miic(hw, PHY_PHYSP_CONTROL, mii_reg);
-
 }
-- 
1.8.3.1
