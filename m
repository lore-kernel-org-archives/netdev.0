From: Mark Brown <broonie@sirena.org.uk>
Subject: [PATCH] e1000: Support e1000 OEMed onto Aculab cards
Date: Mon, 27 Feb 2006 22:05:17 +0000
Message-ID: <20060227220517.GA8611@sirena.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751487AbWB0WFc@vger.kernel.org>
To: cramerj@intel.com, john.ronciak@intel.com,
	ganesh.venkatesan@intel.com
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add PCI IDs for chips OEMed onto some Aculab cards to the e1000 driver.

Signed-Off-By: Mark Brown <broonie@sirena.org.uk>

Index: e1000-queue/drivers/net/e1000/e1000.h
===================================================================
--- e1000-queue.orig/drivers/net/e1000/e1000.h	2006-02-25 12:50:12.000000000 +0000
+++ e1000-queue/drivers/net/e1000/e1000.h	2006-02-25 13:01:10.000000000 +0000
@@ -84,6 +84,9 @@
 #define INTEL_E1000_ETHERNET_DEVICE(device_id) {\
 	PCI_DEVICE(PCI_VENDOR_ID_INTEL, device_id)}
 
+#define ACULAB_E1000_ETHERNET_DEVICE(device_id) {\
+	PCI_DEVICE(PCI_VENDOR_ID_ACULAB, device_id)}
+
 struct e1000_adapter;
 
 #include "e1000_hw.h"
Index: e1000-queue/drivers/net/e1000/e1000_main.c
===================================================================
--- e1000-queue.orig/drivers/net/e1000/e1000_main.c	2006-02-25 12:50:12.000000000 +0000
+++ e1000-queue/drivers/net/e1000/e1000_main.c	2006-02-25 13:01:10.000000000 +0000
@@ -98,6 +98,7 @@ static struct pci_device_id e1000_pci_tb
 	INTEL_E1000_ETHERNET_DEVICE(0x108B),
 	INTEL_E1000_ETHERNET_DEVICE(0x108C),
 	INTEL_E1000_ETHERNET_DEVICE(0x109A),
+	ACULAB_E1000_ETHERNET_DEVICE(0x1078),
 	/* required last entry */
 	{0,}
 };

Index: e1000-queue/include/linux/pci_ids.h
===================================================================
--- e1000-queue.orig/include/linux/pci_ids.h	2006-02-25 12:50:12.000000000 +0000
+++ e1000-queue/include/linux/pci_ids.h	2006-02-25 12:51:51.000000000 +0000
@@ -1572,6 +1572,8 @@
 #define PCI_VENDOR_ID_NVIDIA_SGS	0x12d2
 #define PCI_DEVICE_ID_NVIDIA_SGS_RIVA128 0x0018
 
+#define PCI_VENDOR_ID_ACULAB 0x12d9
+
 #define PCI_SUBVENDOR_ID_CHASE_PCIFAST		0x12E0
 #define PCI_SUBDEVICE_ID_CHASE_PCIFAST4		0x0031
 #define PCI_SUBDEVICE_ID_CHASE_PCIFAST8		0x0021

-- 
"You grabbed my hand and we fell into it, like a daydream - or a fever."
