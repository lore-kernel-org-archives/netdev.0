From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 4/5] ixgbe: Add WoL support for a new device
Date: Thu, 13 Feb 2014 00:00:49 -0800
Message-ID: <1392278450-27062-5-git-send-email-aaron.f.brown@intel.com>
References: <1392278450-27062-1-git-send-email-aaron.f.brown@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:36961 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752156AbaBMIDM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Feb 2014 03:03:12 -0500
In-Reply-To: <1392278450-27062-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

Add WoL support for port 0 of a new 82599-based device.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h | 1 +
 2 files changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 84ca49b..e65a5be 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7800,6 +7800,7 @@ int ixgbe_wol_supported(struct ixgbe_adapter *adapter, u16 device_id,
 	case IXGBE_DEV_ID_82599_SFP:
 		/* Only these subdevices could supports WOL */
 		switch (subdevice_id) {
+		case IXGBE_SUBDEV_ID_82599_SFP_WOL0:
 		case IXGBE_SUBDEV_ID_82599_560FLR:
 			/* only support first port */
 			if (hw->bus.func != 0)
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index 0d39cfc..9283cff 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -54,6 +54,7 @@
 #define IXGBE_DEV_ID_82599_BACKPLANE_FCOE       0x152a
 #define IXGBE_DEV_ID_82599_SFP_FCOE      0x1529
 #define IXGBE_SUBDEV_ID_82599_SFP        0x11A9
+#define IXGBE_SUBDEV_ID_82599_SFP_WOL0   0x1071
 #define IXGBE_SUBDEV_ID_82599_RNDC       0x1F72
 #define IXGBE_SUBDEV_ID_82599_560FLR     0x17D0
 #define IXGBE_SUBDEV_ID_82599_SP_560FLR  0x211B
-- 
1.8.5.GIT
