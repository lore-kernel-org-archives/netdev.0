From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/15] ixgbevf: use PCI_DEVICE_TABLE macro
Date: Fri,  8 Mar 2013 02:07:04 -0800
Message-ID: <1362737237-13363-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1362737237-13363-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:27095 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752764Ab3CHKHX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Mar 2013 05:07:23 -0500
In-Reply-To: <1362737237-13363-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>

Makes PCI id table const. Reformat to match table in ixgbe_main.c

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
Acked-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 20736eb..2635b83 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -76,12 +76,9 @@ static const struct ixgbevf_info *ixgbevf_info_tbl[] = {
  * { Vendor ID, Device ID, SubVendor ID, SubDevice ID,
  *   Class, Class Mask, private data (not used) }
  */
-static struct pci_device_id ixgbevf_pci_tbl[] = {
-	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599_VF),
-	board_82599_vf},
-	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_X540_VF),
-	board_X540_vf},
-
+static DEFINE_PCI_DEVICE_TABLE(ixgbevf_pci_tbl) = {
+	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599_VF), board_82599_vf },
+	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_X540_VF), board_X540_vf },
 	/* required last entry */
 	{0, }
 };
-- 
1.7.11.7
