From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 20/24] ixgbe: add support for new HW
Date: Wed, 13 Apr 2011 18:02:16 -0700
Message-ID: <1302742940-22141-21-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1302742940-22141-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:26341 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758043Ab1DNBCl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2011 21:02:41 -0400
In-Reply-To: <1302742940-22141-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Add new device ID supported by ixgbe.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_82599.c |    1 +
 drivers/net/ixgbe/ixgbe_main.c  |    2 ++
 drivers/net/ixgbe/ixgbe_type.h  |    1 +
 3 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index e39380c..63b4da6 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -359,6 +359,7 @@ static enum ixgbe_media_type ixgbe_get_media_type_82599(struct ixgbe_hw *hw)
 	case IXGBE_DEV_ID_82599_SFP:
 	case IXGBE_DEV_ID_82599_SFP_FCOE:
 	case IXGBE_DEV_ID_82599_SFP_EM:
+	case IXGBE_DEV_ID_82599_SFP_SF2:
 		media_type = ixgbe_media_type_fiber;
 		break;
 	case IXGBE_DEV_ID_82599_CX4:
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 5cd2cd3..200ae7e 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -124,6 +124,8 @@ static DEFINE_PCI_DEVICE_TABLE(ixgbe_pci_tbl) = {
 	 board_82599 },
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_X540T),
 	 board_X540 },
+	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599_SFP_SF2),
+	 board_82599 },
 
 	/* required last entry */
 	{0, }
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index e00356a..15580d6 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -58,6 +58,7 @@
 #define IXGBE_DEV_ID_82599_SFP_FCOE      0x1529
 #define IXGBE_SUBDEV_ID_82599_SFP        0x11A9
 #define IXGBE_DEV_ID_82599_SFP_EM        0x1507
+#define IXGBE_DEV_ID_82599_SFP_SF2       0x154D
 #define IXGBE_DEV_ID_82599_XAUI_LOM      0x10FC
 #define IXGBE_DEV_ID_82599_COMBO_BACKPLANE 0x10F8
 #define IXGBE_SUBDEV_ID_82599_KX4_KR_MEZZ  0x000C
-- 
1.7.4.2

