From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/10] ixgbe: make ixgbe_led_on/off_t_x550em static
Date: Fri, 23 Sep 2016 00:51:35 -0700
Message-ID: <1474617103-59530-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1474617103-59530-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:8864 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754921AbcIWHvp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Sep 2016 03:51:45 -0400
In-Reply-To: <1474617103-59530-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

These functions are only used in ixgbe_x550.c.

Fixes a warning when compiling with -Wmissing-prototypes

Reported-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
index e092a89..dec8b11 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
@@ -2125,7 +2125,7 @@ static s32 ixgbe_reset_phy_t_X550em(struct ixgbe_hw *hw)
  *  @hw: pointer to hardware structure
  *  @led_idx: led number to turn on
  **/
-s32 ixgbe_led_on_t_x550em(struct ixgbe_hw *hw, u32 led_idx)
+static s32 ixgbe_led_on_t_x550em(struct ixgbe_hw *hw, u32 led_idx)
 {
 	u16 phy_data;
 
@@ -2147,7 +2147,7 @@ s32 ixgbe_led_on_t_x550em(struct ixgbe_hw *hw, u32 led_idx)
  *  @hw: pointer to hardware structure
  *  @led_idx: led number to turn off
  **/
-s32 ixgbe_led_off_t_x550em(struct ixgbe_hw *hw, u32 led_idx)
+static s32 ixgbe_led_off_t_x550em(struct ixgbe_hw *hw, u32 led_idx)
 {
 	u16 phy_data;
 
-- 
2.7.4
