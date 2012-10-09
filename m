From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 3/3] e1000e: add device IDs for i218
Date: Tue,  9 Oct 2012 03:13:32 -0700
Message-ID: <1349777612-30149-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1349777612-30149-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:57651 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755251Ab2JIKNv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Oct 2012 06:13:51 -0400
In-Reply-To: <1349777612-30149-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

i218 is the next-generation LOM that will be available on systems with the
Lynx Point LP Platform Controller Hub (PCH) chipset from Intel.  This patch
provides the initial support of those devices.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/hw.h     | 2 ++
 drivers/net/ethernet/intel/e1000e/netdev.c | 2 ++
 2 files changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/intel/e1000e/hw.h b/drivers/net/ethernet/intel/e1000e/hw.h
index ed5b409..d37bfd9 100644
--- a/drivers/net/ethernet/intel/e1000e/hw.h
+++ b/drivers/net/ethernet/intel/e1000e/hw.h
@@ -412,6 +412,8 @@ enum e1e_registers {
 #define E1000_DEV_ID_PCH2_LV_V			0x1503
 #define E1000_DEV_ID_PCH_LPT_I217_LM		0x153A
 #define E1000_DEV_ID_PCH_LPT_I217_V		0x153B
+#define E1000_DEV_ID_PCH_LPTLP_I218_LM		0x155A
+#define E1000_DEV_ID_PCH_LPTLP_I218_V		0x1559
 
 #define E1000_REVISION_4 4
 
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index fb659dd..de57a2b 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -6558,6 +6558,8 @@ static DEFINE_PCI_DEVICE_TABLE(e1000_pci_tbl) = {
 
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_PCH_LPT_I217_LM), board_pch_lpt },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_PCH_LPT_I217_V), board_pch_lpt },
+	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_PCH_LPTLP_I218_LM), board_pch_lpt },
+	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_PCH_LPTLP_I218_V), board_pch_lpt },
 
 	{ 0, 0, 0, 0, 0, 0, 0 }	/* terminate list */
 };
-- 
1.7.11.4
