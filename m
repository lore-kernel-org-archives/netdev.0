From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/17] ixgbe: Provide I2C combined on X550EM
Date: Tue, 22 Sep 2015 16:54:33 -0700
Message-ID: <1442966076-14359-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1442966076-14359-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:50474 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934146AbbIVXyp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Sep 2015 19:54:45 -0400
In-Reply-To: <1442966076-14359-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

Provide I2C combined operations on X550EM, not X550 devices.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
index 9fe9445..2906f08 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
@@ -2039,14 +2039,14 @@ static struct ixgbe_phy_operations phy_ops_X550 = {
 	X550_COMMON_PHY
 	.init			= NULL,
 	.identify		= &ixgbe_identify_phy_generic,
-	.read_i2c_combined	= &ixgbe_read_i2c_combined_generic,
-	.write_i2c_combined	= &ixgbe_write_i2c_combined_generic,
 };
 
 static struct ixgbe_phy_operations phy_ops_X550EM_x = {
 	X550_COMMON_PHY
 	.init			= &ixgbe_init_phy_ops_X550em,
 	.identify		= &ixgbe_identify_phy_x550em,
+	.read_i2c_combined	= &ixgbe_read_i2c_combined_generic,
+	.write_i2c_combined	= &ixgbe_write_i2c_combined_generic,
 };
 
 static const u32 ixgbe_mvals_X550[IXGBE_MVALS_IDX_LIMIT] = {
-- 
2.4.3
