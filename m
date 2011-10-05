From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/10] ixgbe: add support for new 82599 device
Date: Wed,  5 Oct 2011 03:20:20 -0700
Message-ID: <1317810024-20846-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1317810024-20846-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:41269 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934229Ab1JEKUb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Oct 2011 06:20:31 -0400
In-Reply-To: <1317810024-20846-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This patch adds support for new device ID.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c |    1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  |    1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h  |    1 +
 3 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
index 5abd520..cdcf32a 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
@@ -361,6 +361,7 @@ static enum ixgbe_media_type ixgbe_get_media_type_82599(struct ixgbe_hw *hw)
 	case IXGBE_DEV_ID_82599_SFP_FCOE:
 	case IXGBE_DEV_ID_82599_SFP_EM:
 	case IXGBE_DEV_ID_82599_SFP_SF2:
+	case IXGBE_DEV_ID_82599EN_SFP:
 		media_type = ixgbe_media_type_fiber;
 		break;
 	case IXGBE_DEV_ID_82599_CX4:
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 1a3b91f..757e98e 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -105,6 +105,7 @@ static DEFINE_PCI_DEVICE_TABLE(ixgbe_pci_tbl) = {
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_X540T), board_X540 },
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599_SFP_SF2), board_82599 },
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599_LS), board_82599 },
+	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599EN_SFP), board_82599 },
 	/* required last entry */
 	{0, }
 };
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index 838847c..baad0cb 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -59,6 +59,7 @@
 #define IXGBE_SUBDEV_ID_82599_SFP        0x11A9
 #define IXGBE_DEV_ID_82599_SFP_EM        0x1507
 #define IXGBE_DEV_ID_82599_SFP_SF2       0x154D
+#define IXGBE_DEV_ID_82599EN_SFP         0x1557
 #define IXGBE_DEV_ID_82599_XAUI_LOM      0x10FC
 #define IXGBE_DEV_ID_82599_COMBO_BACKPLANE 0x10F8
 #define IXGBE_SUBDEV_ID_82599_KX4_KR_MEZZ  0x000C
-- 
1.7.6.4
