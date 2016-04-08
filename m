From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/18] ixgbe: Add support for single-port X550 device
Date: Thu,  7 Apr 2016 20:21:02 -0700
Message-ID: <1460085673-87056-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1460085673-87056-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:9519 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756939AbcDHDVT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Apr 2016 23:21:19 -0400
In-Reply-To: <1460085673-87056-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

Add support for a single-port X550 device.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c | 1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   | 2 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h   | 1 +
 3 files changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
index ee43a38..8c560da 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
@@ -97,6 +97,7 @@ bool ixgbe_device_supports_autoneg_fc(struct ixgbe_hw *hw)
 		case IXGBE_DEV_ID_X540T:
 		case IXGBE_DEV_ID_X540T1:
 		case IXGBE_DEV_ID_X550T:
+		case IXGBE_DEV_ID_X550T1:
 		case IXGBE_DEV_ID_X550EM_X_10G_T:
 			supported = true;
 			break;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index d5509cc..9594438 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -125,6 +125,7 @@ static const struct pci_device_id ixgbe_pci_tbl[] = {
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599_SFP_SF_QP), board_82599 },
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_X540T1), board_X540 },
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_X550T), board_X550},
+	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_X550T1), board_X550},
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_X550EM_X_KX4), board_X550EM_x},
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_X550EM_X_KR), board_X550EM_x},
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_X550EM_X_10G_T), board_X550EM_x},
@@ -8983,6 +8984,7 @@ int ixgbe_wol_supported(struct ixgbe_adapter *adapter, u16 device_id,
 	case IXGBE_DEV_ID_X540T:
 	case IXGBE_DEV_ID_X540T1:
 	case IXGBE_DEV_ID_X550T:
+	case IXGBE_DEV_ID_X550T1:
 	case IXGBE_DEV_ID_X550EM_X_KX4:
 	case IXGBE_DEV_ID_X550EM_X_KR:
 	case IXGBE_DEV_ID_X550EM_X_10G_T:
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index 7ae4bbd..bd95be2 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -75,6 +75,7 @@
 #define IXGBE_DEV_ID_X540T1              0x1560
 
 #define IXGBE_DEV_ID_X550T		0x1563
+#define IXGBE_DEV_ID_X550T1		0x15D1
 #define IXGBE_DEV_ID_X550EM_X_KX4	0x15AA
 #define IXGBE_DEV_ID_X550EM_X_KR	0x15AB
 #define IXGBE_DEV_ID_X550EM_X_SFP	0x15AC
-- 
2.5.5
