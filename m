From: Cesar Eduardo Barros <cesarb@cesarb.net>
Subject: [PATCH 4/5] sc92031: use device id directly instead of made-up name
Date: Mon, 12 Jan 2009 21:21:50 -0200
Message-ID: <1231802511-14825-4-git-send-email-cesarb@cesarb.net>
References: <496BD04F.2050502@cesarb.net>
Cc: netdev@vger.kernel.org, Cesar Eduardo Barros <cesarb@cesarb.net>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-01.mandic.com.br ([200.225.81.132]:42839 "EHLO
	smtp-01.mandic.com.br" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753775AbZALX2d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2009 18:28:33 -0500
In-Reply-To: <496BD04F.2050502@cesarb.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of making up a name for the device ids, put them directly in the
device id table. Also move the vendor id to pci_ids.h.

Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>
---
 drivers/net/sc92031.c   |    8 ++------
 include/linux/pci_ids.h |    2 ++
 2 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/net/sc92031.c b/drivers/net/sc92031.c
index ac4ccd4..2a111f2 100644
--- a/drivers/net/sc92031.c
+++ b/drivers/net/sc92031.c
@@ -31,10 +31,6 @@
 
 #include <asm/irq.h>
 
-#define PCI_VENDOR_ID_SILAN		0x1904
-#define PCI_DEVICE_ID_SILAN_SC92031	0x2031
-#define PCI_DEVICE_ID_SILAN_8139D	0x8139
-
 #define SC92031_NAME "sc92031"
 
 /* BAR 0 is MMIO, BAR 1 is PIO */
@@ -1591,8 +1587,8 @@ out:
 }
 
 static struct pci_device_id sc92031_pci_device_id_table[] __devinitdata = {
-	{ PCI_DEVICE(PCI_VENDOR_ID_SILAN, PCI_DEVICE_ID_SILAN_SC92031) },
-	{ PCI_DEVICE(PCI_VENDOR_ID_SILAN, PCI_DEVICE_ID_SILAN_8139D) },
+	{ PCI_DEVICE(PCI_VENDOR_ID_SILAN, 0x2031) },
+	{ PCI_DEVICE(PCI_VENDOR_ID_SILAN, 0x8139) },
 	{ 0, }
 };
 MODULE_DEVICE_TABLE(pci, sc92031_pci_device_id_table);
diff --git a/include/linux/pci_ids.h b/include/linux/pci_ids.h
index d543365..c05bc2a 100644
--- a/include/linux/pci_ids.h
+++ b/include/linux/pci_ids.h
@@ -2208,6 +2208,8 @@
 
 #define PCI_VENDOR_ID_TOPSPIN		0x1867
 
+#define PCI_VENDOR_ID_SILAN		0x1904
+
 #define PCI_VENDOR_ID_TDI               0x192E
 #define PCI_DEVICE_ID_TDI_EHCI          0x0101
 
-- 
1.6.1.dirty

