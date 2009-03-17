From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH 07/30] solos: Add initial list of parameters
Date: Tue, 17 Mar 2009 21:29:16 +0000
Message-ID: <1237325356.27681.336.camel@macbook.infradead.org>
References: <1237310370.27681.314.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:37655 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755532AbZCQV3V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 17:29:21 -0400
Received: from macbook.infradead.org ([2001:8b0:10b:1:216:eaff:fe05:bbb8])
	by casper.infradead.org with esmtpsa (Exim 4.69 #1 (Red Hat Linux))
	id 1Ljgqd-0001ux-7Z
	for netdev@vger.kernel.org; Tue, 17 Mar 2009 21:29:19 +0000
In-Reply-To: <1237310370.27681.314.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I don't much like the trick with multiple inclusions of solos-attrlist.c
but don't really see a saner way to do it without repeating the list.

Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
---
 drivers/atm/solos-attrlist.c |   70 ++++++++++++++++++++++++++++++++++++++++++
 drivers/atm/solos-pci.c      |   30 ++++++++++++++---
 2 files changed, 94 insertions(+), 6 deletions(-)
 create mode 100644 drivers/atm/solos-attrlist.c

diff --git a/drivers/atm/solos-attrlist.c b/drivers/atm/solos-attrlist.c
new file mode 100644
index 0000000..efa2808
--- /dev/null
+++ b/drivers/atm/solos-attrlist.c
@@ -0,0 +1,70 @@
+SOLOS_ATTR_RO(DriverVersion)
+SOLOS_ATTR_RO(APIVersion)
+SOLOS_ATTR_RO(FirmwareVersion)
+// SOLOS_ATTR_RO(DspVersion)
+// SOLOS_ATTR_RO(CommonHandshake)
+SOLOS_ATTR_RO(Connected)
+SOLOS_ATTR_RO(OperationalMode)
+SOLOS_ATTR_RO(State)
+SOLOS_ATTR_RO(Watchdog)
+SOLOS_ATTR_RO(OperationProgress)
+SOLOS_ATTR_RO(LastFailed)
+SOLOS_ATTR_RO(TxBitRate)
+SOLOS_ATTR_RO(RxBitRate)
+// SOLOS_ATTR_RO(DeltACTATPds)
+// SOLOS_ATTR_RO(DeltACTATPus)
+SOLOS_ATTR_RO(TxATTNDR)
+SOLOS_ATTR_RO(RxATTNDR)
+SOLOS_ATTR_RO(AnnexType)
+SOLOS_ATTR_RO(GeneralFailure)
+SOLOS_ATTR_RO(InterleaveDpDn)
+SOLOS_ATTR_RO(InterleaveDpUp)
+SOLOS_ATTR_RO(RSCorrectedErrorsDn)
+SOLOS_ATTR_RO(RSUnCorrectedErrorsDn)
+SOLOS_ATTR_RO(RSCorrectedErrorsUp)
+SOLOS_ATTR_RO(RSUnCorrectedErrorsUp)
+SOLOS_ATTR_RO(InterleaveRDn)
+SOLOS_ATTR_RO(InterleaveRUp)
+SOLOS_ATTR_RO(ShowtimeStart)
+SOLOS_ATTR_RO(ATURVendor)
+SOLOS_ATTR_RO(ATUCCountry)
+SOLOS_ATTR_RO(ATURANSIRev)
+SOLOS_ATTR_RO(ATURANSISTD)
+SOLOS_ATTR_RO(ATUCANSIRev)
+SOLOS_ATTR_RO(ATUCANSIId)
+SOLOS_ATTR_RO(ATUCANSISTD)
+SOLOS_ATTR_RO(DataBoost)
+SOLOS_ATTR_RO(LocalITUCountryCode)
+SOLOS_ATTR_RO(LocalSEF)
+SOLOS_ATTR_RO(LocalEndLOS)
+SOLOS_ATTR_RO(LocalSNRMargin)
+SOLOS_ATTR_RO(LocalLineAttn)
+SOLOS_ATTR_RO(RawAttn)
+SOLOS_ATTR_RO(LocalTxPower)
+SOLOS_ATTR_RO(RemoteTxPower)
+SOLOS_ATTR_RO(RemoteSEF)
+SOLOS_ATTR_RO(RemoteLOS)
+SOLOS_ATTR_RO(RemoteLineAttn)
+SOLOS_ATTR_RO(RemoteSNRMargin)
+SOLOS_ATTR_RO(LineUpCount)
+SOLOS_ATTR_RO(SRACnt)
+SOLOS_ATTR_RO(SRACntUp)
+SOLOS_ATTR_RO(ProfileStatus)
+SOLOS_ATTR_RW(Action)
+SOLOS_ATTR_RW(ActivateLine)
+SOLOS_ATTR_RO(LineStatus)
+SOLOS_ATTR_RW(HostControl)
+SOLOS_ATTR_RW(AutoStart)
+SOLOS_ATTR_RW(Failsafe)
+SOLOS_ATTR_RW(ShowtimeLed)
+SOLOS_ATTR_RW(Retrain)
+SOLOS_ATTR_RW(Defaults)
+SOLOS_ATTR_RW(LineMode)
+SOLOS_ATTR_RW(Profile)
+SOLOS_ATTR_RW(DetectNoise)
+SOLOS_ATTR_RO(SupportedAnnexes)
+SOLOS_ATTR_RO(Status)
+SOLOS_ATTR_RO(TotalStart)
+SOLOS_ATTR_RO(RecentShowtimeStart)
+SOLOS_ATTR_RO(TotalRxBlocks)
+SOLOS_ATTR_RO(TotalTxBlocks)
diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index d9262a4..b0c4676 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -371,8 +371,28 @@ static ssize_t console_store(struct device *dev, struct device_attribute *attr,
 }
 
 static DEVICE_ATTR(console, 0644, console_show, console_store);
-static DEVICE_ATTR(OperationalMode, 0444, solos_param_show, NULL);
-static DEVICE_ATTR(AutoStart, 0644, solos_param_show, solos_param_store);
+
+
+#define SOLOS_ATTR_RO(x) static DEVICE_ATTR(x, 0444, solos_param_show, NULL);
+#define SOLOS_ATTR_RW(x) static DEVICE_ATTR(x, 0644, solos_param_show, solos_param_store);
+
+#include "solos-attrlist.c"
+
+#undef SOLOS_ATTR_RO
+#undef SOLOS_ATTR_RW
+
+#define SOLOS_ATTR_RO(x) &dev_attr_##x.attr,
+#define SOLOS_ATTR_RW(x) &dev_attr_##x.attr,
+
+static struct attribute *solos_attrs[] = {
+#include "solos-attrlist.c"
+	NULL
+};
+
+static struct attribute_group solos_attr_group = {
+	.attrs = solos_attrs,
+	.name = "parameters",
+};
 
 static int flash_upgrade(struct solos_card *card, int chip)
 {
@@ -987,10 +1007,8 @@ static int atm_init(struct solos_card *card)
 		}
 		if (device_create_file(&card->atmdev[i]->class_dev, &dev_attr_console))
 			dev_err(&card->dev->dev, "Could not register console for ATM device %d\n", i);
-		if (device_create_file(&card->atmdev[i]->class_dev, &dev_attr_OperationalMode))
-			dev_err(&card->dev->dev, "Could not register opmode attr for ATM device %d\n", i);
-		if (device_create_file(&card->atmdev[i]->class_dev, &dev_attr_AutoStart))
-			dev_err(&card->dev->dev, "Could not register autostart attr for ATM device %d\n", i);
+		if (sysfs_create_group(&card->atmdev[i]->class_dev.kobj, &solos_attr_group))
+			dev_err(&card->dev->dev, "Could not register parameter group for ATM device %d\n", i);
 
 		dev_info(&card->dev->dev, "Registered ATM device %d\n", card->atmdev[i]->number);
 
-- 
1.6.0.6


