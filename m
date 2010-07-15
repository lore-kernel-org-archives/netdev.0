From: Peter Huewe <PeterHuewe@gmx.de>
Subject: [PATCH 21/25] isdn/hardware/eicon: Convert pci_table entries to PCI_VDEVICE (if PCI_ANY_ID is used)
Date: Thu, 15 Jul 2010 21:04:45 +0200
Message-ID: <201007152104.45958.PeterHuewe@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Armin Schindler <mac@melware.de>,
	Karsten Keil <isdn@linux-pingi.de>,
	"David S. Miller" <davem@davemloft.net>,
	Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
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
 drivers/isdn/hardware/eicon/divasmain.c |   69 +++++++++++++++----------------
 1 files changed, 34 insertions(+), 35 deletions(-)

diff --git a/drivers/isdn/hardware/eicon/divasmain.c b/drivers/isdn/hardware/eicon/divasmain.c
index 16a874b..ed9c555 100644
--- a/drivers/isdn/hardware/eicon/divasmain.c
+++ b/drivers/isdn/hardware/eicon/divasmain.c
@@ -112,41 +112,40 @@ typedef struct _diva_os_thread_dpc {
   This table should be sorted by PCI device ID
   */
 static struct pci_device_id divas_pci_tbl[] = {
-/* Diva Server BRI-2M PCI 0xE010 */
-	{PCI_VENDOR_ID_EICON, PCI_DEVICE_ID_EICON_MAESTRA,
-	 PCI_ANY_ID, PCI_ANY_ID, 0, 0, CARDTYPE_MAESTRA_PCI},
-/* Diva Server 4BRI-8M PCI 0xE012 */
-	{PCI_VENDOR_ID_EICON, PCI_DEVICE_ID_EICON_MAESTRAQ,
-	 PCI_ANY_ID, PCI_ANY_ID, 0, 0, CARDTYPE_DIVASRV_Q_8M_PCI},
-/* Diva Server 4BRI-8M 2.0 PCI 0xE013 */
-	{PCI_VENDOR_ID_EICON, PCI_DEVICE_ID_EICON_MAESTRAQ_U,
-	 PCI_ANY_ID, PCI_ANY_ID, 0, 0, CARDTYPE_DIVASRV_Q_8M_V2_PCI},
-/* Diva Server PRI-30M PCI 0xE014 */
-	{PCI_VENDOR_ID_EICON, PCI_DEVICE_ID_EICON_MAESTRAP,
-	 PCI_ANY_ID, PCI_ANY_ID, 0, 0, CARDTYPE_DIVASRV_P_30M_PCI},
-/* Diva Server PRI 2.0 adapter 0xE015 */
-	{PCI_VENDOR_ID_EICON, PCI_DEVICE_ID_EICON_MAESTRAP_2,
-	 PCI_ANY_ID, PCI_ANY_ID, 0, 0, CARDTYPE_DIVASRV_P_30M_V2_PCI},
-/* Diva Server Voice 4BRI-8M PCI 0xE016 */
-	{PCI_VENDOR_ID_EICON, PCI_DEVICE_ID_EICON_4BRI_VOIP,
-	 PCI_ANY_ID, PCI_ANY_ID, 0, 0, CARDTYPE_DIVASRV_VOICE_Q_8M_PCI},
-/* Diva Server Voice 4BRI-8M 2.0 PCI 0xE017 */
-	{PCI_VENDOR_ID_EICON, PCI_DEVICE_ID_EICON_4BRI_2_VOIP,
-	 PCI_ANY_ID, PCI_ANY_ID, 0, 0, CARDTYPE_DIVASRV_VOICE_Q_8M_V2_PCI},
-/* Diva Server BRI-2M 2.0 PCI 0xE018 */
-	{PCI_VENDOR_ID_EICON, PCI_DEVICE_ID_EICON_BRI2M_2,
-	 PCI_ANY_ID, PCI_ANY_ID, 0, 0, CARDTYPE_DIVASRV_B_2M_V2_PCI},
-/* Diva Server Voice PRI 2.0 PCI 0xE019 */
-	{PCI_VENDOR_ID_EICON, PCI_DEVICE_ID_EICON_MAESTRAP_2_VOIP,
-	 PCI_ANY_ID, PCI_ANY_ID, 0, 0,
-	 CARDTYPE_DIVASRV_VOICE_P_30M_V2_PCI},
-/* Diva Server 2FX 0xE01A */
-	{PCI_VENDOR_ID_EICON, PCI_DEVICE_ID_EICON_2F,
-	 PCI_ANY_ID, PCI_ANY_ID, 0, 0, CARDTYPE_DIVASRV_B_2F_PCI},
-/* Diva Server Voice BRI-2M 2.0 PCI 0xE01B */
-	{PCI_VENDOR_ID_EICON, PCI_DEVICE_ID_EICON_BRI2M_2_VOIP,
-	 PCI_ANY_ID, PCI_ANY_ID, 0, 0, CARDTYPE_DIVASRV_VOICE_B_2M_V2_PCI},
-	{0,}			/* 0 terminated list. */
+	/* Diva Server BRI-2M PCI 0xE010 */
+	{ PCI_VDEVICE(EICON, PCI_DEVICE_ID_EICON_MAESTRA),
+		CARDTYPE_MAESTRA_PCI },
+	/* Diva Server 4BRI-8M PCI 0xE012 */
+	{ PCI_VDEVICE(EICON, PCI_DEVICE_ID_EICON_MAESTRAQ),
+		CARDTYPE_DIVASRV_Q_8M_PCI },
+	/* Diva Server 4BRI-8M 2.0 PCI 0xE013 */
+	{ PCI_VDEVICE(EICON, PCI_DEVICE_ID_EICON_MAESTRAQ_U),
+		CARDTYPE_DIVASRV_Q_8M_V2_PCI },
+	/* Diva Server PRI-30M PCI 0xE014 */
+	{ PCI_VDEVICE(EICON, PCI_DEVICE_ID_EICON_MAESTRAP),
+		CARDTYPE_DIVASRV_P_30M_PCI },
+	/* Diva Server PRI 2.0 adapter 0xE015 */
+	{ PCI_VDEVICE(EICON, PCI_DEVICE_ID_EICON_MAESTRAP_2),
+		CARDTYPE_DIVASRV_P_30M_V2_PCI },
+	/* Diva Server Voice 4BRI-8M PCI 0xE016 */
+	{ PCI_VDEVICE(EICON, PCI_DEVICE_ID_EICON_4BRI_VOIP),
+		CARDTYPE_DIVASRV_VOICE_Q_8M_PCI },
+	/* Diva Server Voice 4BRI-8M 2.0 PCI 0xE017 */
+	{ PCI_VDEVICE(EICON, PCI_DEVICE_ID_EICON_4BRI_2_VOIP),
+		CARDTYPE_DIVASRV_VOICE_Q_8M_V2_PCI },
+	/* Diva Server BRI-2M 2.0 PCI 0xE018 */
+	{ PCI_VDEVICE(EICON, PCI_DEVICE_ID_EICON_BRI2M_2),
+		CARDTYPE_DIVASRV_B_2M_V2_PCI },
+	/* Diva Server Voice PRI 2.0 PCI 0xE019 */
+	{ PCI_VDEVICE(EICON, PCI_DEVICE_ID_EICON_MAESTRAP_2_VOIP),
+		CARDTYPE_DIVASRV_VOICE_P_30M_V2_PCI },
+	/* Diva Server 2FX 0xE01A */
+	{ PCI_VDEVICE(EICON, PCI_DEVICE_ID_EICON_2F),
+		CARDTYPE_DIVASRV_B_2F_PCI },
+	/* Diva Server Voice BRI-2M 2.0 PCI 0xE01B */
+	{ PCI_VDEVICE(EICON, PCI_DEVICE_ID_EICON_BRI2M_2_VOIP),
+		CARDTYPE_DIVASRV_VOICE_B_2M_V2_PCI },
+	{ 0, }			/* 0 terminated list. */
 };
 MODULE_DEVICE_TABLE(pci, divas_pci_tbl);
 
-- 
1.7.1
