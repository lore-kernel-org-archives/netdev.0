From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/12] e1000e: Initial Support for IceLake
Date: Wed,  9 Aug 2017 14:47:42 -0700
Message-ID: <20170809214746.28139-9-jeffrey.t.kirsher@intel.com>
References: <20170809214746.28139-1-jeffrey.t.kirsher@intel.com>
Cc: Sasha Neftin <sasha.neftin@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:31102 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752342AbdHIVr5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 9 Aug 2017 17:47:57 -0400
In-Reply-To: <20170809214746.28139-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sasha Neftin <sasha.neftin@intel.com>

i219 (8) and i219 (9) are the next LOM generations that will be available
on the next Intel Client platform (IceLake).
This patch provides the initial support for these devices

Signed-off-by: Sasha Neftin <sasha.neftin@intel.com>
Reviewed-by: Raanan Avargil <raanan.avargil@intel.com>
Reviewed-by: Dima Ruinskiy <dima.ruinskiy@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/hw.h     | 4 ++++
 drivers/net/ethernet/intel/e1000e/netdev.c | 4 ++++
 2 files changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/intel/e1000e/hw.h b/drivers/net/ethernet/intel/e1000e/hw.h
index 66bd5060a65b..d803b1a12349 100644
--- a/drivers/net/ethernet/intel/e1000e/hw.h
+++ b/drivers/net/ethernet/intel/e1000e/hw.h
@@ -100,6 +100,10 @@ struct e1000_hw;
 #define E1000_DEV_ID_PCH_CNP_I219_V6		0x15BE
 #define E1000_DEV_ID_PCH_CNP_I219_LM7		0x15BB
 #define E1000_DEV_ID_PCH_CNP_I219_V7		0x15BC
+#define E1000_DEV_ID_PCH_ICP_I219_LM8		0x15DF
+#define E1000_DEV_ID_PCH_ICP_I219_V8		0x15E0
+#define E1000_DEV_ID_PCH_ICP_I219_LM9		0x15E1
+#define E1000_DEV_ID_PCH_ICP_I219_V9		0x15E2
 
 #define E1000_REVISION_4	4
 
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 2dcb5463d9b8..327dfe5bedc0 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -7544,6 +7544,10 @@ static const struct pci_device_id e1000_pci_tbl[] = {
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_PCH_CNP_I219_V6), board_pch_cnp },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_PCH_CNP_I219_LM7), board_pch_cnp },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_PCH_CNP_I219_V7), board_pch_cnp },
+	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_PCH_ICP_I219_LM8), board_pch_cnp },
+	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_PCH_ICP_I219_V8), board_pch_cnp },
+	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_PCH_ICP_I219_LM9), board_pch_cnp },
+	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_PCH_ICP_I219_V9), board_pch_cnp },
 
 	{ 0, 0, 0, 0, 0, 0, 0 }	/* terminate list */
 };
-- 
2.13.3
