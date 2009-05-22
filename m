From: Karsten Keil <keil-shG/GajIFYqbacvFa/9K2g@public.gmane.org>
Subject: [mISDN PATCH v2 15/19] Add PCI ID for Junghanns 8S card
Date: Fri, 22 May 2009 23:04:55 +0200
Message-ID: <e27193109e9bb5f33e0a408b5b9674375d073bda.1243024967.git.kkeil@pingi.linux-pingi.de>
References: <cover.1243024967.git.kkeil@pingi.linux-pingi.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        i4ldeveloper-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <i4ldeveloper-bounces-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org>
In-Reply-To: <cover.1243024967.git.kkeil-Zw2aQviYsaUCyFmpLCWB8V3+hHH5wKcB@public.gmane.org>
List-Unsubscribe: <https://www.isdn4linux.de/mailman/listinfo/i4ldeveloper>,
	<mailto:i4ldeveloper-request-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org?subject=unsubscribe>
List-Archive: <http://www.isdn4linux.de/pipermail/i4ldeveloper>
List-Post: <mailto:i4ldeveloper-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org>
List-Help: <mailto:i4ldeveloper-request-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org?subject=help>
List-Subscribe: <https://www.isdn4linux.de/mailman/listinfo/i4ldeveloper>,
	<mailto:i4ldeveloper-request-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org?subject=subscribe>
Sender: i4ldeveloper-bounces-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org
Errors-To: i4ldeveloper-bounces-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Andreas Eversberg <andreas-BhNU7qSqiUAcB3Tz54LwoQ@public.gmane.org>

new id for HFC-8S

Signed-off-by: Andreas Eversberg <andreas-BhNU7qSqiUAcB3Tz54LwoQ@public.gmane.org>
Signed-off-by: Karsten Keil <keil-shG/GajIFYqbacvFa/9K2g@public.gmane.org>
---
 drivers/isdn/hardware/mISDN/hfcmulti.c |    3 +++
 include/linux/pci_ids.h                |    1 +
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/isdn/hardware/mISDN/hfcmulti.c b/drivers/isdn/hardware/mISDN/hfcmulti.c
index 5be4edf..50e9f4d 100644
--- a/drivers/isdn/hardware/mISDN/hfcmulti.c
+++ b/drivers/isdn/hardware/mISDN/hfcmulti.c
@@ -5275,6 +5275,7 @@ static const struct hm_map hfcm_map[] = {
 /*30*/	{VENDOR_CCD, "HFC-8S OpenVox", 8, 8, 1, 0, 0, 0, 0, 0},
 /*31*/	{VENDOR_CCD, "XHFC-4S Speech Design", 5, 4, 0, 0, 0, 0,
 		HFC_IO_MODE_EMBSD, XHFC_IRQ},
+/*32*/	{VENDOR_JH, "HFC-8S (junghanns)", 8, 8, 1, 0, 0, 0, 0, 0},
 };
 
 #undef H
@@ -5328,6 +5329,8 @@ static struct pci_device_id hfmultipci_ids[] __devinitdata = {
 		PCI_SUBDEVICE_ID_CCD_HFC8S, 0, 0, H(18)}, /* 8S */
 	{ PCI_VENDOR_ID_CCD, PCI_DEVICE_ID_CCD_HFC8S, PCI_VENDOR_ID_CCD,
 		PCI_SUBDEVICE_ID_CCD_OV8S, 0, 0, H(30)}, /* OpenVox 8 */
+	{ PCI_VENDOR_ID_CCD, PCI_DEVICE_ID_CCD_HFC8S, PCI_VENDOR_ID_CCD,
+		PCI_SUBDEVICE_ID_CCD_JH8S, 0, 0, H(32)}, /* Junganns 8S  */
 
 
 	/* Cards with HFC-E1 Chip */
diff --git a/include/linux/pci_ids.h b/include/linux/pci_ids.h
index 3038ac2..4bdff98 100644
--- a/include/linux/pci_ids.h
+++ b/include/linux/pci_ids.h
@@ -1914,6 +1914,7 @@
 #define PCI_SUBDEVICE_ID_CCD_SWYX4S	0xB540
 #define PCI_SUBDEVICE_ID_CCD_JH4S20	0xB550
 #define PCI_SUBDEVICE_ID_CCD_IOB8ST_1	0xB552
+#define PCI_SUBDEVICE_ID_CCD_JH8S	0xB55B
 #define PCI_SUBDEVICE_ID_CCD_BN4S	0xB560
 #define PCI_SUBDEVICE_ID_CCD_BN8S	0xB562
 #define PCI_SUBDEVICE_ID_CCD_BNE1	0xB563
-- 
1.6.0.2
