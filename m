From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/20] e1000e: Initial support for KabeLake
Date: Tue, 23 Feb 2016 20:26:09 -0800
Message-ID: <1456287984-10459-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1456287984-10459-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Raanan Avargil <raanan.avargil@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:51525 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757351AbcBXE0a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Feb 2016 23:26:30 -0500
In-Reply-To: <1456287984-10459-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raanan Avargil <raanan.avargil@intel.com>

i219 (4) and i219 (5) are the next LOM generations that will be
available on the next Intel platform (KabeLake).
This patch provides the initial support for the devices.

Signed-off-by: Raanan Avargil <raanan.avargil@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/hw.h     | 4 ++++
 drivers/net/ethernet/intel/e1000e/netdev.c | 4 ++++
 2 files changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/intel/e1000e/hw.h b/drivers/net/ethernet/intel/e1000e/hw.h
index b3949d5..4e733bf 100644
--- a/drivers/net/ethernet/intel/e1000e/hw.h
+++ b/drivers/net/ethernet/intel/e1000e/hw.h
@@ -92,6 +92,10 @@ struct e1000_hw;
 #define E1000_DEV_ID_PCH_SPT_I219_LM2		0x15B7	/* SPT-H PCH */
 #define E1000_DEV_ID_PCH_SPT_I219_V2		0x15B8	/* SPT-H PCH */
 #define E1000_DEV_ID_PCH_LBG_I219_LM3		0x15B9	/* LBG PCH */
+#define E1000_DEV_ID_PCH_SPT_I219_LM4		0x15D7
+#define E1000_DEV_ID_PCH_SPT_I219_V4		0x15D8
+#define E1000_DEV_ID_PCH_SPT_I219_LM5		0x15E3
+#define E1000_DEV_ID_PCH_SPT_I219_V5		0x15D6
 
 #define E1000_REVISION_4	4
 
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index c71ba1b..9b4ec13 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -7452,6 +7452,10 @@ static const struct pci_device_id e1000_pci_tbl[] = {
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_PCH_SPT_I219_LM2), board_pch_spt },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_PCH_SPT_I219_V2), board_pch_spt },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_PCH_LBG_I219_LM3), board_pch_spt },
+	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_PCH_SPT_I219_LM4), board_pch_spt },
+	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_PCH_SPT_I219_V4), board_pch_spt },
+	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_PCH_SPT_I219_LM5), board_pch_spt },
+	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_PCH_SPT_I219_V5), board_pch_spt },
 
 	{ 0, 0, 0, 0, 0, 0, 0 }	/* terminate list */
 };
-- 
2.5.0
