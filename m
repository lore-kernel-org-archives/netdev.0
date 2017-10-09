From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/10] ixgbe: declare ixgbe_mac_operations structures as const
Date: Mon,  9 Oct 2017 11:39:52 -0700
Message-ID: <20171009184000.80053-3-jeffrey.t.kirsher@intel.com>
References: <20171009184000.80053-1-jeffrey.t.kirsher@intel.com>
Cc: Bhumika Goyal <bhumirks@gmail.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:50188 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755212AbdJISkW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Oct 2017 14:40:22 -0400
In-Reply-To: <20171009184000.80053-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bhumika Goyal <bhumirks@gmail.com>

Declare ixgbe_mac_operations structures as const as they are only stored
in the mac_ops field of ixgbe_info structure. This field is of type
const and therefore ixgbe_mac_operations structure can be made const
too.

Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
index 19fbb2f28ea4..933c5070f1b6 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
@@ -3884,7 +3884,7 @@ static const struct ixgbe_mac_operations mac_ops_X550EM_x_fw = {
 	.write_iosf_sb_reg	= ixgbe_write_iosf_sb_reg_x550,
 };
 
-static struct ixgbe_mac_operations mac_ops_x550em_a = {
+static const struct ixgbe_mac_operations mac_ops_x550em_a = {
 	X550_COMMON_MAC
 	.led_on			= ixgbe_led_on_t_x550em,
 	.led_off		= ixgbe_led_off_t_x550em,
@@ -3905,7 +3905,7 @@ static struct ixgbe_mac_operations mac_ops_x550em_a = {
 	.write_iosf_sb_reg	= ixgbe_write_iosf_sb_reg_x550a,
 };
 
-static struct ixgbe_mac_operations mac_ops_x550em_a_fw = {
+static const struct ixgbe_mac_operations mac_ops_x550em_a_fw = {
 	X550_COMMON_MAC
 	.led_on			= ixgbe_led_on_generic,
 	.led_off		= ixgbe_led_off_generic,
-- 
2.14.2
