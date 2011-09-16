From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/11] ixgbe: combine PCI_VDEVICE and board declaration to same line
Date: Thu, 15 Sep 2011 21:42:49 -0700
Message-ID: <1316148173-11209-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1316148173-11209-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:15976 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752034Ab1IPEm7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Sep 2011 00:42:59 -0400
In-Reply-To: <1316148173-11209-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch is a minor whitespace cleanup to compress the device ID
declaration and board type declaration onto the same line.  It seems to
make sense since all of the combinations of the two are less than 80
characters and it makes the overall layout a bit more readable.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   79 ++++++++-----------------
 1 files changed, 26 insertions(+), 53 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index dd1b57b..fee5630 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -79,59 +79,32 @@ static const struct ixgbe_info *ixgbe_info_tbl[] = {
  *   Class, Class Mask, private data (not used) }
  */
 static DEFINE_PCI_DEVICE_TABLE(ixgbe_pci_tbl) = {
-	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82598),
-	 board_82598 },
-	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82598AF_DUAL_PORT),
-	 board_82598 },
-	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82598AF_SINGLE_PORT),
-	 board_82598 },
-	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82598AT),
-	 board_82598 },
-	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82598AT2),
-	 board_82598 },
-	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82598EB_CX4),
-	 board_82598 },
-	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82598_CX4_DUAL_PORT),
-	 board_82598 },
-	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82598_DA_DUAL_PORT),
-	 board_82598 },
-	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82598_SR_DUAL_PORT_EM),
-	 board_82598 },
-	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82598EB_XF_LR),
-	 board_82598 },
-	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82598EB_SFP_LOM),
-	 board_82598 },
-	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82598_BX),
-	 board_82598 },
-	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599_KX4),
-	 board_82599 },
-	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599_XAUI_LOM),
-	 board_82599 },
-	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599_KR),
-	 board_82599 },
-	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599_SFP),
-	 board_82599 },
-	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599_SFP_EM),
-	 board_82599 },
-	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599_KX4_MEZZ),
-	 board_82599 },
-	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599_CX4),
-	 board_82599 },
-	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599_BACKPLANE_FCOE),
-	 board_82599 },
-	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599_SFP_FCOE),
-	 board_82599 },
-	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599_T3_LOM),
-	 board_82599 },
-	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599_COMBO_BACKPLANE),
-	 board_82599 },
-	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_X540T),
-	 board_X540 },
-	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599_SFP_SF2),
-	 board_82599 },
-	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599_LS),
-	 board_82599 },
-
+	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82598), board_82598 },
+	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82598AF_DUAL_PORT), board_82598 },
+	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82598AF_SINGLE_PORT), board_82598 },
+	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82598AT), board_82598 },
+	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82598AT2), board_82598 },
+	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82598EB_CX4), board_82598 },
+	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82598_CX4_DUAL_PORT), board_82598 },
+	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82598_DA_DUAL_PORT), board_82598 },
+	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82598_SR_DUAL_PORT_EM), board_82598 },
+	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82598EB_XF_LR), board_82598 },
+	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82598EB_SFP_LOM), board_82598 },
+	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82598_BX), board_82598 },
+	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599_KX4), board_82599 },
+	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599_XAUI_LOM), board_82599 },
+	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599_KR), board_82599 },
+	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599_SFP), board_82599 },
+	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599_SFP_EM), board_82599 },
+	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599_KX4_MEZZ), board_82599 },
+	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599_CX4), board_82599 },
+	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599_BACKPLANE_FCOE), board_82599 },
+	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599_SFP_FCOE), board_82599 },
+	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599_T3_LOM), board_82599 },
+	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599_COMBO_BACKPLANE), board_82599 },
+	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_X540T), board_X540 },
+	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599_SFP_SF2), board_82599 },
+	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599_LS), board_82599 },
 	/* required last entry */
 	{0, }
 };
-- 
1.7.6
