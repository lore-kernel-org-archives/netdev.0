From: Jon Mason <jon.mason@intel.com>
Subject: [PATCH 07/21] NTB: zero PCI driver data
Date: Sat, 19 Jan 2013 02:02:21 -0700
Message-ID: <1358586155-23322-8-git-send-email-jon.mason@intel.com>
References: <1358586155-23322-1-git-send-email-jon.mason@intel.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Dave Jiang <dave.jiang@intel.com>,
	Nicholas Bellinger <nab@linux-iscsi.org>
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1358586155-23322-1-git-send-email-jon.mason@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Zero pci_device_id driver_data variable.  Unused, but 'EXTRA_CFLAGS=-W'
complained of uninitialized variables.

Signed-off-by: Jon Mason <jon.mason@intel.com>
---
 drivers/ntb/ntb_hw.c |   16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/ntb/ntb_hw.c b/drivers/ntb/ntb_hw.c
index 0b46fef..867ccaa 100644
--- a/drivers/ntb/ntb_hw.c
+++ b/drivers/ntb/ntb_hw.c
@@ -83,14 +83,14 @@ enum {
 #define MW_TO_BAR(mw)	(mw * 2 + 2)
 
 static DEFINE_PCI_DEVICE_TABLE(ntb_pci_tbl) = {
-	{PCI_VDEVICE(INTEL, PCI_DEVICE_ID_INTEL_NTB_B2B_BWD)},
-	{PCI_VDEVICE(INTEL, PCI_DEVICE_ID_INTEL_NTB_B2B_JSF)},
-	{PCI_VDEVICE(INTEL, PCI_DEVICE_ID_INTEL_NTB_CLASSIC_JSF)},
-	{PCI_VDEVICE(INTEL, PCI_DEVICE_ID_INTEL_NTB_RP_JSF)},
-	{PCI_VDEVICE(INTEL, PCI_DEVICE_ID_INTEL_NTB_RP_SNB)},
-	{PCI_VDEVICE(INTEL, PCI_DEVICE_ID_INTEL_NTB_B2B_SNB)},
-	{PCI_VDEVICE(INTEL, PCI_DEVICE_ID_INTEL_NTB_CLASSIC_SNB)},
-	{0}
+	{PCI_VDEVICE(INTEL, PCI_DEVICE_ID_INTEL_NTB_B2B_BWD),		0},
+	{PCI_VDEVICE(INTEL, PCI_DEVICE_ID_INTEL_NTB_B2B_JSF),		0},
+	{PCI_VDEVICE(INTEL, PCI_DEVICE_ID_INTEL_NTB_CLASSIC_JSF),	0},
+	{PCI_VDEVICE(INTEL, PCI_DEVICE_ID_INTEL_NTB_RP_JSF),		0},
+	{PCI_VDEVICE(INTEL, PCI_DEVICE_ID_INTEL_NTB_RP_SNB),		0},
+	{PCI_VDEVICE(INTEL, PCI_DEVICE_ID_INTEL_NTB_B2B_SNB),		0},
+	{PCI_VDEVICE(INTEL, PCI_DEVICE_ID_INTEL_NTB_CLASSIC_SNB),	0},
+	{0, 0, 0, 0, 0, 0, 0}
 };
 MODULE_DEVICE_TABLE(pci, ntb_pci_tbl);
 
-- 
1.7.9.5
