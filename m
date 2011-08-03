From: Jon Mason <jdmason@kudzu.us>
Subject: [resend PATCH] irda: use PCI_VENDOR_ID_*
Date: Wed,  3 Aug 2011 11:42:42 -0500
Message-ID: <1312389762-9728-1-git-send-email-jdmason@kudzu.us>
Cc: netdev@vger.kernel.org, Samuel Ortiz <samuel@sortiz.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:38616 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754392Ab1HCQmr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2011 12:42:47 -0400
Received: by gyh3 with SMTP id 3so574114gyh.19
        for <netdev@vger.kernel.org>; Wed, 03 Aug 2011 09:42:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use PCI_VENDOR_ID_* from pci_ids.h instead of creating #define locally.

Signed-off-by: Jon Mason <jdmason@kudzu.us>
---
 drivers/net/irda/smsc-ircc2.c |   18 ++++++++----------
 1 files changed, 8 insertions(+), 10 deletions(-)

diff --git a/drivers/net/irda/smsc-ircc2.c b/drivers/net/irda/smsc-ircc2.c
index 954f6e93..8b1c348 100644
--- a/drivers/net/irda/smsc-ircc2.c
+++ b/drivers/net/irda/smsc-ircc2.c
@@ -2405,8 +2405,6 @@ static int __init smsc_superio_lpc(unsigned short cfg_base)
  * addresses making a subsystem device table necessary.
  */
 #ifdef CONFIG_PCI
-#define PCIID_VENDOR_INTEL 0x8086
-#define PCIID_VENDOR_ALI 0x10b9
 static struct smsc_ircc_subsystem_configuration subsystem_configurations[] __initdata = {
 	/*
 	 * Subsystems needing entries:
@@ -2416,7 +2414,7 @@ static struct smsc_ircc_subsystem_configuration subsystem_configurations[] __ini
 	 */
 	{
 		/* Guessed entry */
-		.vendor = PCIID_VENDOR_INTEL, /* Intel 82801DBM LPC bridge */
+		.vendor = PCI_VENDOR_ID_INTEL, /* Intel 82801DBM LPC bridge */
 		.device = 0x24cc,
 		.subvendor = 0x103c,
 		.subdevice = 0x08bc,
@@ -2429,7 +2427,7 @@ static struct smsc_ircc_subsystem_configuration subsystem_configurations[] __ini
 		.name = "HP nx5000 family",
 	},
 	{
-		.vendor = PCIID_VENDOR_INTEL, /* Intel 82801DBM LPC bridge */
+		.vendor = PCI_VENDOR_ID_INTEL, /* Intel 82801DBM LPC bridge */
 		.device = 0x24cc,
 		.subvendor = 0x103c,
 		.subdevice = 0x088c,
@@ -2443,7 +2441,7 @@ static struct smsc_ircc_subsystem_configuration subsystem_configurations[] __ini
 		.name = "HP nc8000 family",
 	},
 	{
-		.vendor = PCIID_VENDOR_INTEL, /* Intel 82801DBM LPC bridge */
+		.vendor = PCI_VENDOR_ID_INTEL, /* Intel 82801DBM LPC bridge */
 		.device = 0x24cc,
 		.subvendor = 0x103c,
 		.subdevice = 0x0890,
@@ -2456,7 +2454,7 @@ static struct smsc_ircc_subsystem_configuration subsystem_configurations[] __ini
 		.name = "HP nc6000 family",
 	},
 	{
-		.vendor = PCIID_VENDOR_INTEL, /* Intel 82801DBM LPC bridge */
+		.vendor = PCI_VENDOR_ID_INTEL, /* Intel 82801DBM LPC bridge */
 		.device = 0x24cc,
 		.subvendor = 0x0e11,
 		.subdevice = 0x0860,
@@ -2471,7 +2469,7 @@ static struct smsc_ircc_subsystem_configuration subsystem_configurations[] __ini
 	},
 	{
 		/* Intel 82801DB/DBL (ICH4/ICH4-L) LPC Interface Bridge */
-		.vendor = PCIID_VENDOR_INTEL,
+		.vendor = PCI_VENDOR_ID_INTEL,
 		.device = 0x24c0,
 		.subvendor = 0x1179,
 		.subdevice = 0xffff, /* 0xffff is "any" */
@@ -2484,7 +2482,7 @@ static struct smsc_ircc_subsystem_configuration subsystem_configurations[] __ini
 		.name = "Toshiba laptop with Intel 82801DB/DBL LPC bridge",
 	},
 	{
-		.vendor = PCIID_VENDOR_INTEL, /* Intel 82801CAM ISA bridge */
+		.vendor = PCI_VENDOR_ID_INTEL, /* Intel 82801CAM ISA bridge */
 		.device = 0x248c,
 		.subvendor = 0x1179,
 		.subdevice = 0xffff, /* 0xffff is "any" */
@@ -2498,7 +2496,7 @@ static struct smsc_ircc_subsystem_configuration subsystem_configurations[] __ini
 	},
 	{
 		/* 82801DBM (ICH4-M) LPC Interface Bridge */
-		.vendor = PCIID_VENDOR_INTEL,
+		.vendor = PCI_VENDOR_ID_INTEL,
 		.device = 0x24cc,
 		.subvendor = 0x1179,
 		.subdevice = 0xffff, /* 0xffff is "any" */
@@ -2512,7 +2510,7 @@ static struct smsc_ircc_subsystem_configuration subsystem_configurations[] __ini
 	},
 	{
 		/* ALi M1533/M1535 PCI to ISA Bridge [Aladdin IV/V/V+] */
-		.vendor = PCIID_VENDOR_ALI,
+		.vendor = PCI_VENDOR_ID_AL,
 		.device = 0x1533,
 		.subvendor = 0x1179,
 		.subdevice = 0xffff, /* 0xffff is "any" */
-- 
1.7.6

