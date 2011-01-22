From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 4/4] igb: Add support for i340 Quad Port Fiber Adapter
Date: Sat, 22 Jan 2011 03:56:16 -0800
Message-ID: <1295697376-2984-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1295697376-2984-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:32805 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752903Ab1AVL4c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Jan 2011 06:56:32 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <1295697376-2984-1-git-send-email-jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch enables support for Intel i340 Quad Port Fiber Adapter.

Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/igb/e1000_82575.c |    1 +
 drivers/net/igb/e1000_hw.h    |    1 +
 drivers/net/igb/igb_main.c    |    1 +
 3 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/igb/e1000_82575.c
index 0a2368f..c1552b6 100644
--- a/drivers/net/igb/e1000_82575.c
+++ b/drivers/net/igb/e1000_82575.c
@@ -129,6 +129,7 @@ static s32 igb_get_invariants_82575(struct e1000_hw *hw)
 		break;
 	case E1000_DEV_ID_82580_COPPER:
 	case E1000_DEV_ID_82580_FIBER:
+	case E1000_DEV_ID_82580_QUAD_FIBER:
 	case E1000_DEV_ID_82580_SERDES:
 	case E1000_DEV_ID_82580_SGMII:
 	case E1000_DEV_ID_82580_COPPER_DUAL:
diff --git a/drivers/net/igb/e1000_hw.h b/drivers/net/igb/e1000_hw.h
index e2638af..281324e 100644
--- a/drivers/net/igb/e1000_hw.h
+++ b/drivers/net/igb/e1000_hw.h
@@ -54,6 +54,7 @@ struct e1000_hw;
 #define E1000_DEV_ID_82580_SERDES             0x1510
 #define E1000_DEV_ID_82580_SGMII              0x1511
 #define E1000_DEV_ID_82580_COPPER_DUAL        0x1516
+#define E1000_DEV_ID_82580_QUAD_FIBER         0x1527
 #define E1000_DEV_ID_DH89XXCC_SGMII           0x0438
 #define E1000_DEV_ID_DH89XXCC_SERDES          0x043A
 #define E1000_DEV_ID_DH89XXCC_BACKPLANE       0x043C
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 58c665b..200cc32 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -68,6 +68,7 @@ static DEFINE_PCI_DEVICE_TABLE(igb_pci_tbl) = {
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_I350_SGMII), board_82575 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82580_COPPER), board_82575 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82580_FIBER), board_82575 },
+	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82580_QUAD_FIBER), board_82575 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82580_SERDES), board_82575 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82580_SGMII), board_82575 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82580_COPPER_DUAL), board_82575 },
-- 
1.7.3.4

