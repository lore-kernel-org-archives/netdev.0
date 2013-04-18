From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/15] ixgbe: Add support for WoL on 82599 SFP+ LOM
Date: Thu, 18 Apr 2013 16:30:09 -0700
Message-ID: <1366327822-10741-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1366327822-10741-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:59537 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936672Ab3DRXas (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Apr 2013 19:30:48 -0400
In-Reply-To: <1366327822-10741-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This patch adds software support for WoL for the 82599 SFP+ LOM device,
(ID 0x8976)

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h | 1 +
 2 files changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 48f3fd5..aa5d7d0 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7206,6 +7206,7 @@ int ixgbe_wol_supported(struct ixgbe_adapter *adapter, u16 device_id,
 		case IXGBE_SUBDEV_ID_82599_SFP:
 		case IXGBE_SUBDEV_ID_82599_RNDC:
 		case IXGBE_SUBDEV_ID_82599_ECNA_DP:
+		case IXGBE_SUBDEV_ID_82599_LOM_SFP:
 			is_wol_supported = 1;
 			break;
 		}
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index 155a793..402f1a2 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -57,6 +57,7 @@
 #define IXGBE_SUBDEV_ID_82599_RNDC       0x1F72
 #define IXGBE_SUBDEV_ID_82599_560FLR     0x17D0
 #define IXGBE_SUBDEV_ID_82599_ECNA_DP    0x0470
+#define IXGBE_SUBDEV_ID_82599_LOM_SFP    0x8976
 #define IXGBE_DEV_ID_82599_SFP_EM        0x1507
 #define IXGBE_DEV_ID_82599_SFP_SF2       0x154D
 #define IXGBE_DEV_ID_82599EN_SFP         0x1557
-- 
1.7.11.7
