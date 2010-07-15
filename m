From: Peter Huewe <PeterHuewe@gmx.de>
Subject: [PATCH 19/25] isdn/hardware/mISDN: Convert pci_table entries to PCI_VDEVICE (if PCI_ANY_ID is used)
Date: Thu, 15 Jul 2010 21:02:36 +0200
Message-ID: <201007152102.38008.PeterHuewe@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Karsten Keil <isdn@linux-pingi.de>,
	"Uwe =?iso-8859-1?q?Kleine-K=F6nig?="
	<u.kleine-koenig@pengutronix.de>, Tejun Heo <tj@kernel.org>,
	Jiri Kosina <jkosina@suse.cz>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Kernel Janitors <kernel-janitors@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Peter Huewe <peterhuewe@gmx.de>

This patch converts pci_table entries, where .subvendor=PCI_ANY_ID and
.subdevice=PCI_ANY_ID, .class=0 and .class_mask=0, to use the
PCI_VDEVICE macro, and thus improves readability.

Signed-off-by: Peter Huewe <peterhuewe@gmx.de>
---
 drivers/isdn/hardware/mISDN/hfcpci.c |   92 +++++++++++++++++-----------------
 1 files changed, 46 insertions(+), 46 deletions(-)

diff --git a/drivers/isdn/hardware/mISDN/hfcpci.c b/drivers/isdn/hardware/mISDN/hfcpci.c
index 65ded05..15d323b 100644
--- a/drivers/isdn/hardware/mISDN/hfcpci.c
+++ b/drivers/isdn/hardware/mISDN/hfcpci.c
@@ -2188,52 +2188,52 @@ static const struct _hfc_map hfc_map[] =
 
 static struct pci_device_id hfc_ids[] =
 {
-	{PCI_VENDOR_ID_CCD, PCI_DEVICE_ID_CCD_2BD0,
-		PCI_ANY_ID, PCI_ANY_ID, 0, 0, (unsigned long) &hfc_map[0]},
-	{PCI_VENDOR_ID_CCD, PCI_DEVICE_ID_CCD_B000,
-		PCI_ANY_ID, PCI_ANY_ID, 0, 0, (unsigned long) &hfc_map[1]},
-	{PCI_VENDOR_ID_CCD, PCI_DEVICE_ID_CCD_B006,
-		PCI_ANY_ID, PCI_ANY_ID, 0, 0, (unsigned long) &hfc_map[2]},
-	{PCI_VENDOR_ID_CCD, PCI_DEVICE_ID_CCD_B007,
-		PCI_ANY_ID, PCI_ANY_ID, 0, 0, (unsigned long) &hfc_map[3]},
-	{PCI_VENDOR_ID_CCD, PCI_DEVICE_ID_CCD_B008,
-		PCI_ANY_ID, PCI_ANY_ID, 0, 0, (unsigned long) &hfc_map[4]},
-	{PCI_VENDOR_ID_CCD, PCI_DEVICE_ID_CCD_B009,
-		PCI_ANY_ID, PCI_ANY_ID, 0, 0, (unsigned long) &hfc_map[5]},
-	{PCI_VENDOR_ID_CCD, PCI_DEVICE_ID_CCD_B00A,
-		PCI_ANY_ID, PCI_ANY_ID, 0, 0, (unsigned long) &hfc_map[6]},
-	{PCI_VENDOR_ID_CCD, PCI_DEVICE_ID_CCD_B00B,
-		PCI_ANY_ID, PCI_ANY_ID, 0, 0, (unsigned long) &hfc_map[7]},
-	{PCI_VENDOR_ID_CCD, PCI_DEVICE_ID_CCD_B00C,
-		PCI_ANY_ID, PCI_ANY_ID, 0, 0, (unsigned long) &hfc_map[8]},
-	{PCI_VENDOR_ID_CCD, PCI_DEVICE_ID_CCD_B100,
-		PCI_ANY_ID, PCI_ANY_ID, 0, 0, (unsigned long) &hfc_map[9]},
-	{PCI_VENDOR_ID_CCD, PCI_DEVICE_ID_CCD_B700,
-		PCI_ANY_ID, PCI_ANY_ID, 0, 0, (unsigned long) &hfc_map[10]},
-	{PCI_VENDOR_ID_CCD, PCI_DEVICE_ID_CCD_B701,
-		PCI_ANY_ID, PCI_ANY_ID, 0, 0, (unsigned long) &hfc_map[11]},
-	{PCI_VENDOR_ID_ABOCOM, PCI_DEVICE_ID_ABOCOM_2BD1,
-		PCI_ANY_ID, PCI_ANY_ID, 0, 0, (unsigned long) &hfc_map[12]},
-	{PCI_VENDOR_ID_ASUSTEK, PCI_DEVICE_ID_ASUSTEK_0675,
-		PCI_ANY_ID, PCI_ANY_ID, 0, 0, (unsigned long) &hfc_map[13]},
-	{PCI_VENDOR_ID_BERKOM, PCI_DEVICE_ID_BERKOM_T_CONCEPT,
-		PCI_ANY_ID, PCI_ANY_ID, 0, 0, (unsigned long) &hfc_map[14]},
-	{PCI_VENDOR_ID_BERKOM, PCI_DEVICE_ID_BERKOM_A1T,
-		PCI_ANY_ID, PCI_ANY_ID, 0, 0, (unsigned long) &hfc_map[15]},
-	{PCI_VENDOR_ID_ANIGMA, PCI_DEVICE_ID_ANIGMA_MC145575,
-		PCI_ANY_ID, PCI_ANY_ID, 0, 0, (unsigned long) &hfc_map[16]},
-	{PCI_VENDOR_ID_ZOLTRIX, PCI_DEVICE_ID_ZOLTRIX_2BD0,
-		PCI_ANY_ID, PCI_ANY_ID, 0, 0, (unsigned long) &hfc_map[17]},
-	{PCI_VENDOR_ID_DIGI, PCI_DEVICE_ID_DIGI_DF_M_IOM2_E,
-		PCI_ANY_ID, PCI_ANY_ID, 0, 0, (unsigned long) &hfc_map[18]},
-	{PCI_VENDOR_ID_DIGI, PCI_DEVICE_ID_DIGI_DF_M_E,
-		PCI_ANY_ID, PCI_ANY_ID, 0, 0, (unsigned long) &hfc_map[19]},
-	{PCI_VENDOR_ID_DIGI, PCI_DEVICE_ID_DIGI_DF_M_IOM2_A,
-		PCI_ANY_ID, PCI_ANY_ID, 0, 0, (unsigned long) &hfc_map[20]},
-	{PCI_VENDOR_ID_DIGI, PCI_DEVICE_ID_DIGI_DF_M_A,
-		PCI_ANY_ID, PCI_ANY_ID, 0, 0, (unsigned long) &hfc_map[21]},
-	{PCI_VENDOR_ID_SITECOM, PCI_DEVICE_ID_SITECOM_DC105V2,
-		PCI_ANY_ID, PCI_ANY_ID, 0, 0, (unsigned long) &hfc_map[22]},
+	{ PCI_VDEVICE(CCD, PCI_DEVICE_ID_CCD_2BD0),
+		(unsigned long) &hfc_map[0] },
+	{ PCI_VDEVICE(CCD, PCI_DEVICE_ID_CCD_B000),
+		(unsigned long) &hfc_map[1] },
+	{ PCI_VDEVICE(CCD, PCI_DEVICE_ID_CCD_B006),
+		(unsigned long) &hfc_map[2] },
+	{ PCI_VDEVICE(CCD, PCI_DEVICE_ID_CCD_B007),
+		(unsigned long) &hfc_map[3] },
+	{ PCI_VDEVICE(CCD, PCI_DEVICE_ID_CCD_B008),
+		(unsigned long) &hfc_map[4] },
+	{ PCI_VDEVICE(CCD, PCI_DEVICE_ID_CCD_B009),
+		(unsigned long) &hfc_map[5] },
+	{ PCI_VDEVICE(CCD, PCI_DEVICE_ID_CCD_B00A),
+		(unsigned long) &hfc_map[6] },
+	{ PCI_VDEVICE(CCD, PCI_DEVICE_ID_CCD_B00B),
+		(unsigned long) &hfc_map[7] },
+	{ PCI_VDEVICE(CCD, PCI_DEVICE_ID_CCD_B00C),
+		(unsigned long) &hfc_map[8] },
+	{ PCI_VDEVICE(CCD, PCI_DEVICE_ID_CCD_B100),
+		(unsigned long) &hfc_map[9] },
+	{ PCI_VDEVICE(CCD, PCI_DEVICE_ID_CCD_B700),
+		(unsigned long) &hfc_map[10] },
+	{ PCI_VDEVICE(CCD, PCI_DEVICE_ID_CCD_B701),
+		(unsigned long) &hfc_map[11] },
+	{ PCI_VDEVICE(ABOCOM, PCI_DEVICE_ID_ABOCOM_2BD1),
+		(unsigned long) &hfc_map[12] },
+	{ PCI_VDEVICE(ASUSTEK, PCI_DEVICE_ID_ASUSTEK_0675),
+		(unsigned long) &hfc_map[13] },
+	{ PCI_VDEVICE(BERKOM, PCI_DEVICE_ID_BERKOM_T_CONCEPT),
+		(unsigned long) &hfc_map[14] },
+	{ PCI_VDEVICE(BERKOM, PCI_DEVICE_ID_BERKOM_A1T),
+		(unsigned long) &hfc_map[15] },
+	{ PCI_VDEVICE(ANIGMA, PCI_DEVICE_ID_ANIGMA_MC145575),
+		(unsigned long) &hfc_map[16] },
+	{ PCI_VDEVICE(ZOLTRIX, PCI_DEVICE_ID_ZOLTRIX_2BD0),
+		(unsigned long) &hfc_map[17] },
+	{ PCI_VDEVICE(DIGI, PCI_DEVICE_ID_DIGI_DF_M_IOM2_E),
+		(unsigned long) &hfc_map[18] },
+	{ PCI_VDEVICE(DIGI, PCI_DEVICE_ID_DIGI_DF_M_E),
+		(unsigned long) &hfc_map[19] },
+	{ PCI_VDEVICE(DIGI, PCI_DEVICE_ID_DIGI_DF_M_IOM2_A),
+		(unsigned long) &hfc_map[20] },
+	{ PCI_VDEVICE(DIGI, PCI_DEVICE_ID_DIGI_DF_M_A),
+		(unsigned long) &hfc_map[21] },
+	{ PCI_VDEVICE(SITECOM, PCI_DEVICE_ID_SITECOM_DC105V2),
+		(unsigned long) &hfc_map[22] },
 	{},
 };
 
-- 
1.7.1
