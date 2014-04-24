From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/13] igb: Cleanups to replace deprecated DEFINE_PCI_DEVICE_TABLE
Date: Thu, 24 Apr 2014 03:30:57 -0700
Message-ID: <1398335460-4283-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1398335460-4283-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:25294 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755960AbaDXKbJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Apr 2014 06:31:09 -0400
In-Reply-To: <1398335460-4283-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch changes implementation to remove use of DEFINE_PCI_DEVICE_TABLE.
This patch fixes WARNING:DEFINE_PCI_DEVICE_TABLE

Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 1926ca1..2fc1b5b 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -72,7 +72,7 @@ static const struct e1000_info *igb_info_tbl[] = {
 	[board_82575] = &e1000_82575_info,
 };
 
-static DEFINE_PCI_DEVICE_TABLE(igb_pci_tbl) = {
+static const struct pci_device_id igb_pci_tbl[] = {
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_I354_BACKPLANE_1GBPS) },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_I354_SGMII) },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_I354_BACKPLANE_2_5GBPS) },
-- 
1.9.0
