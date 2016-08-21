From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 5/6] ixgbe: add device to MDIO speed setting
Date: Sat, 20 Aug 2016 20:22:21 -0700
Message-ID: <1471749742-7080-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1471749742-7080-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:24499 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752517AbcHUDW0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 20 Aug 2016 23:22:26 -0400
In-Reply-To: <1471749742-7080-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

This shouldn't matter as nothing should be attached still to be
consisted control MDIO speed for these devices as well.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
index 45ad6b1..a8030e0 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
@@ -2558,6 +2558,8 @@ static void ixgbe_set_mdio_speed(struct ixgbe_hw *hw)
 
 	switch (hw->device_id) {
 	case IXGBE_DEV_ID_X550EM_X_10G_T:
+	case IXGBE_DEV_ID_X550EM_A_SGMII:
+	case IXGBE_DEV_ID_X550EM_A_SGMII_L:
 	case IXGBE_DEV_ID_X550EM_A_SFP:
 		/* Config MDIO clock speed before the first MDIO PHY access */
 		hlreg0 = IXGBE_READ_REG(hw, IXGBE_HLREG0);
-- 
2.7.4
