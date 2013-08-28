From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next  06/10] ixgbe: cleanup some log messages
Date: Wed, 28 Aug 2013 03:33:44 -0700
Message-ID: <1377686028-30747-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1377686028-30747-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:34607 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753556Ab3H1Kd4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Aug 2013 06:33:56 -0400
In-Reply-To: <1377686028-30747-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

Some minor log messages cleanup, changing the level one message is logged,
adding a bit of detail to another and put all the text on one line.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 6 ++----
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c  | 2 +-
 2 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index cf1b41e..4688057 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7605,10 +7605,8 @@ static int ixgbe_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	    hw->mac.type == ixgbe_mac_82598EB) {
 		err = 0;
 	} else if (err == IXGBE_ERR_SFP_NOT_SUPPORTED) {
-		e_dev_err("failed to load because an unsupported SFP+ "
-			  "module type was detected.\n");
-		e_dev_err("Reload the driver after installing a supported "
-			  "module.\n");
+		e_dev_err("failed to load because an unsupported SFP+ or QSFP module type was detected.\n");
+		e_dev_err("Reload the driver after installing a supported module.\n");
 		goto err_sw_init;
 	} else if (err) {
 		e_dev_err("HW Init failed: %d\n", err);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
index 6a4a799..033997b 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
@@ -1282,7 +1282,7 @@ s32 ixgbe_identify_qsfp_module_generic(struct ixgbe_hw *hw)
 				status = 0;
 			} else {
 				if (hw->allow_unsupported_sfp == true) {
-					e_warn(hw, "WARNING: Intel (R) Network Connections are quality tested using Intel (R) Ethernet Optics. Using untested modules is not supported and may cause unstable operation or damage to the module or the adapter. Intel Corporation is not responsible for any harm caused by using untested modules.\n");
+					e_warn(drv, "WARNING: Intel (R) Network Connections are quality tested using Intel (R) Ethernet Optics. Using untested modules is not supported and may cause unstable operation or damage to the module or the adapter. Intel Corporation is not responsible for any harm caused by using untested modules.\n");
 					status = 0;
 				} else {
 					hw_dbg(hw,
-- 
1.8.3.1
