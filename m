From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 39/40] ixgbe: update driver version string
Date: Tue,  7 Jun 2011 05:33:14 -0700
Message-ID: <1307449995-9458-40-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1307449995-9458-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:56636 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753385Ab1FGMdf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jun 2011 08:33:35 -0400
In-Reply-To: <1307449995-9458-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

Update the ixgbe driver version string to better match the Source Driver
with similar device support.  Likewise update to the current LAD Linux
versioning scheme.

Signed-of-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Evan Swanson <evan.swanson@intel.com>

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_main.c |    8 ++++----
 drivers/net/ixgbe/ixgbe_type.h |    3 ++-
 2 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index a5425e8..cb52ff8 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -53,11 +53,10 @@ char ixgbe_driver_name[] = "ixgbe";
 static const char ixgbe_driver_string[] =
 			      "Intel(R) 10 Gigabit PCI Express Network Driver";
 #define MAJ 3
-#define MIN 3
+#define MIN 4
 #define BUILD 8
-#define KFIX 2
 #define DRV_VERSION __stringify(MAJ) "." __stringify(MIN) "." \
-	__stringify(BUILD) "-k" __stringify(KFIX)
+	__stringify(BUILD) "-k"
 const char ixgbe_driver_version[] = DRV_VERSION;
 static const char ixgbe_copyright[] =
 				"Copyright (c) 1999-2011 Intel Corporation.";
@@ -7723,7 +7722,8 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 
 	/* Inform firmware of driver version */
 	if (hw->mac.ops.set_fw_drv_ver)
-		hw->mac.ops.set_fw_drv_ver(hw, MAJ, MIN, BUILD, KFIX);
+		hw->mac.ops.set_fw_drv_ver(hw, MAJ, MIN, BUILD,
+					   FW_CEM_UNUSED_VER);
 
 	/* add san mac addr to netdev */
 	ixgbe_add_sanmac_netdev(netdev);
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index 8b1abd4..1eefc0c 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -2143,7 +2143,8 @@ enum ixgbe_fdir_pballoc_type {
 #define FW_CEM_HDR_LEN                0x4
 #define FW_CEM_CMD_DRIVER_INFO        0xDD
 #define FW_CEM_CMD_DRIVER_INFO_LEN    0x5
-#define FW_CEM_CMD_RESERVED           0X0
+#define FW_CEM_CMD_RESERVED           0x0
+#define FW_CEM_UNUSED_VER             0x0
 #define FW_CEM_MAX_RETRIES            3
 #define FW_CEM_RESP_STATUS_SUCCESS    0x1
 
-- 
1.7.5.2

