From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/7] e1000e: remove unnecessary parentheses
Date: Fri, 10 Feb 2012 00:08:53 -0800
Message-ID: <1328861337-12810-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1328861337-12810-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:3668 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754026Ab2BJIJB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Feb 2012 03:09:01 -0500
In-Reply-To: <1328861337-12810-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/82571.c   |    2 +-
 drivers/net/ethernet/intel/e1000e/ethtool.c |    4 ++--
 drivers/net/ethernet/intel/e1000e/mac.c     |    6 +++---
 drivers/net/ethernet/intel/e1000e/manage.c  |    2 +-
 drivers/net/ethernet/intel/e1000e/phy.c     |   10 +++++-----
 5 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/82571.c b/drivers/net/ethernet/intel/e1000e/82571.c
index 4cadcc7..7ef4711 100644
--- a/drivers/net/ethernet/intel/e1000e/82571.c
+++ b/drivers/net/ethernet/intel/e1000e/82571.c
@@ -1865,7 +1865,7 @@ static void e1000_power_down_phy_copper_82571(struct e1000_hw *hw)
 	struct e1000_phy_info *phy = &hw->phy;
 	struct e1000_mac_info *mac = &hw->mac;
 
-	if (!(phy->ops.check_reset_block))
+	if (!phy->ops.check_reset_block)
 		return;
 
 	/* If the management interface is not enabled, then power down */
diff --git a/drivers/net/ethernet/intel/e1000e/ethtool.c b/drivers/net/ethernet/intel/e1000e/ethtool.c
index f4dc0fa..b1f5d74 100644
--- a/drivers/net/ethernet/intel/e1000e/ethtool.c
+++ b/drivers/net/ethernet/intel/e1000e/ethtool.c
@@ -1088,7 +1088,7 @@ static int e1000_setup_desc_rings(struct e1000_adapter *adapter)
 	tx_ring->buffer_info = kcalloc(tx_ring->count,
 				       sizeof(struct e1000_buffer),
 				       GFP_KERNEL);
-	if (!(tx_ring->buffer_info)) {
+	if (!tx_ring->buffer_info) {
 		ret_val = 1;
 		goto err_nomem;
 	}
@@ -1150,7 +1150,7 @@ static int e1000_setup_desc_rings(struct e1000_adapter *adapter)
 	rx_ring->buffer_info = kcalloc(rx_ring->count,
 				       sizeof(struct e1000_buffer),
 				       GFP_KERNEL);
-	if (!(rx_ring->buffer_info)) {
+	if (!rx_ring->buffer_info) {
 		ret_val = 5;
 		goto err_nomem;
 	}
diff --git a/drivers/net/ethernet/intel/e1000e/mac.c b/drivers/net/ethernet/intel/e1000e/mac.c
index be8335a..0d63c3e 100644
--- a/drivers/net/ethernet/intel/e1000e/mac.c
+++ b/drivers/net/ethernet/intel/e1000e/mac.c
@@ -511,8 +511,8 @@ s32 e1000e_check_for_fiber_link(struct e1000_hw *hw)
 	 * was just plugged in. The autoneg_failed flag does this.
 	 */
 	/* (ctrl & E1000_CTRL_SWDPIN1) == 1 == have signal */
-	if ((ctrl & E1000_CTRL_SWDPIN1) && (!(status & E1000_STATUS_LU)) &&
-	    (!(rxcw & E1000_RXCW_C))) {
+	if ((ctrl & E1000_CTRL_SWDPIN1) && !(status & E1000_STATUS_LU) &&
+	    !(rxcw & E1000_RXCW_C)) {
 		if (mac->autoneg_failed == 0) {
 			mac->autoneg_failed = 1;
 			return 0;
@@ -577,7 +577,7 @@ s32 e1000e_check_for_serdes_link(struct e1000_hw *hw)
 	 * time to complete.
 	 */
 	/* (ctrl & E1000_CTRL_SWDPIN1) == 1 == have signal */
-	if ((!(status & E1000_STATUS_LU)) && (!(rxcw & E1000_RXCW_C))) {
+	if (!(status & E1000_STATUS_LU) && !(rxcw & E1000_RXCW_C)) {
 		if (mac->autoneg_failed == 0) {
 			mac->autoneg_failed = 1;
 			return 0;
diff --git a/drivers/net/ethernet/intel/e1000e/manage.c b/drivers/net/ethernet/intel/e1000e/manage.c
index 6594dbf..c54caf6 100644
--- a/drivers/net/ethernet/intel/e1000e/manage.c
+++ b/drivers/net/ethernet/intel/e1000e/manage.c
@@ -78,7 +78,7 @@ static s32 e1000_mng_enable_host_if(struct e1000_hw *hw)
 	u32 hicr;
 	u8 i;
 
-	if (!(hw->mac.arc_subsystem_valid)) {
+	if (!hw->mac.arc_subsystem_valid) {
 		e_dbg("ARC subsystem not valid.\n");
 		return -E1000_ERR_HOST_INTERFACE_COMMAND;
 	}
diff --git a/drivers/net/ethernet/intel/e1000e/phy.c b/drivers/net/ethernet/intel/e1000e/phy.c
index 8dd2ff0..e8ad080 100644
--- a/drivers/net/ethernet/intel/e1000e/phy.c
+++ b/drivers/net/ethernet/intel/e1000e/phy.c
@@ -132,7 +132,7 @@ s32 e1000e_get_phy_id(struct e1000_hw *hw)
 	u16 phy_id;
 	u16 retry_count = 0;
 
-	if (!(phy->ops.read_reg))
+	if (!phy->ops.read_reg)
 		goto out;
 
 	while (retry_count < 2) {
@@ -382,7 +382,7 @@ static s32 __e1000e_read_phy_reg_igp(struct e1000_hw *hw, u32 offset, u16 *data,
 	s32 ret_val = 0;
 
 	if (!locked) {
-		if (!(hw->phy.ops.acquire))
+		if (!hw->phy.ops.acquire)
 			goto out;
 
 		ret_val = hw->phy.ops.acquire(hw);
@@ -453,7 +453,7 @@ static s32 __e1000e_write_phy_reg_igp(struct e1000_hw *hw, u32 offset, u16 data,
 	s32 ret_val = 0;
 
 	if (!locked) {
-		if (!(hw->phy.ops.acquire))
+		if (!hw->phy.ops.acquire)
 			goto out;
 
 		ret_val = hw->phy.ops.acquire(hw);
@@ -526,7 +526,7 @@ static s32 __e1000_read_kmrn_reg(struct e1000_hw *hw, u32 offset, u16 *data,
 	s32 ret_val = 0;
 
 	if (!locked) {
-		if (!(hw->phy.ops.acquire))
+		if (!hw->phy.ops.acquire)
 			goto out;
 
 		ret_val = hw->phy.ops.acquire(hw);
@@ -599,7 +599,7 @@ static s32 __e1000_write_kmrn_reg(struct e1000_hw *hw, u32 offset, u16 data,
 	s32 ret_val = 0;
 
 	if (!locked) {
-		if (!(hw->phy.ops.acquire))
+		if (!hw->phy.ops.acquire)
 			goto out;
 
 		ret_val = hw->phy.ops.acquire(hw);
-- 
1.7.7.6
