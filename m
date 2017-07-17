From: Bhumika Goyal <bhumirks@gmail.com>
Subject: [PATCH] ixgbe: declare ixgbe_mac_operations structures as const
Date: Mon, 17 Jul 2017 20:31:18 +0530
Message-ID: <1500303678-5403-1-git-send-email-bhumirks@gmail.com>
Cc: Bhumika Goyal <bhumirks@gmail.com>
To: julia.lawall@lip6.fr, jeffrey.t.kirsher@intel.com,
        intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Declare ixgbe_mac_operations structures as const as they are only stored
in the mac_ops field of ixgbe_info structure. This field is of type
const and therefore ixgbe_mac_operations structure can be made const
too.

Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
index 72d84a0..b290a0d 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
@@ -3858,7 +3858,7 @@ static s32 ixgbe_write_phy_reg_x550a(struct ixgbe_hw *hw, u32 reg_addr,
 	.write_iosf_sb_reg	= ixgbe_write_iosf_sb_reg_x550,
 };
 
-static struct ixgbe_mac_operations mac_ops_x550em_a = {
+static const struct ixgbe_mac_operations mac_ops_x550em_a = {
 	X550_COMMON_MAC
 	.led_on			= ixgbe_led_on_t_x550em,
 	.led_off		= ixgbe_led_off_t_x550em,
@@ -3879,7 +3879,7 @@ static s32 ixgbe_write_phy_reg_x550a(struct ixgbe_hw *hw, u32 reg_addr,
 	.write_iosf_sb_reg	= ixgbe_write_iosf_sb_reg_x550a,
 };
 
-static struct ixgbe_mac_operations mac_ops_x550em_a_fw = {
+static const struct ixgbe_mac_operations mac_ops_x550em_a_fw = {
 	X550_COMMON_MAC
 	.led_on			= ixgbe_led_on_generic,
 	.led_off		= ixgbe_led_off_generic,
-- 
1.9.1
