From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [patch 8/8 2.5] e1000 - White space changes, driver version number
 update and others
Date: Fri, 17 Sep 2004 02:58:29 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0409170239280.15233-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: ganesh.venkatesan@intel.com, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -up linux-2.5/drivers/net/e1000/e1000_ethtool.c linux-2.5/drivers/net/e1000.new/e1000_ethtool.c
--- linux-2.5/drivers/net/e1000/e1000_ethtool.c	2004-09-09 11:17:11.000000000 -0700
+++ linux-2.5/drivers/net/e1000.new/e1000_ethtool.c	2004-09-09 11:17:12.000000000 -0700
@@ -637,7 +637,6 @@ err_setup_rx:
 	return err;
 }
 
-
 #define REG_PATTERN_TEST(R, M, W)                                              \
 {                                                                              \
 	uint32_t pat, value;                                                   \
diff -up linux-2.5/drivers/net/e1000/e1000.h linux-2.5/drivers/net/e1000.new/e1000.h
--- linux-2.5/drivers/net/e1000/e1000.h	2004-09-09 11:17:11.000000000 -0700
+++ linux-2.5/drivers/net/e1000.new/e1000.h	2004-09-09 11:17:12.000000000 -0700
@@ -75,6 +75,8 @@
 #define BAR_0		0
 #define BAR_1		1
 #define BAR_5		5
+#define PCI_DMA_64BIT	0xffffffffffffffffULL
+#define PCI_DMA_32BIT	0x00000000ffffffffULL
 
 #define INTEL_E1000_ETHERNET_DEVICE(device_id) {\
 	PCI_DEVICE(PCI_VENDOR_ID_INTEL, device_id)}
diff -up linux-2.5/drivers/net/e1000/e1000_main.c linux-2.5/drivers/net/e1000.new/e1000_main.c
--- linux-2.5/drivers/net/e1000/e1000_main.c	2004-09-09 11:17:11.000000000 -0700
+++ linux-2.5/drivers/net/e1000.new/e1000_main.c	2004-09-09 11:17:12.000000000 -0700
@@ -48,7 +48,7 @@ char e1000_driver_string[] = "Intel(R) P
 #else
 #define DRIVERNAPI "-NAPI"
 #endif
-char e1000_driver_version[] = "5.3.19-k2"DRIVERNAPI;
+char e1000_driver_version[] = "5.4.11"DRIVERNAPI;
 char e1000_copyright[] = "Copyright (c) 1999-2004 Intel Corporation.";
 
 /* e1000_pci_tbl - PCI Device ID Table
@@ -386,10 +386,10 @@ e1000_probe(struct pci_dev *pdev,
 	if((err = pci_enable_device(pdev)))
 		return err;
 
-	if(!(err = pci_set_dma_mask(pdev, DMA_64BIT_MASK))) {
+	if(!(err = pci_set_dma_mask(pdev, PCI_DMA_64BIT))) {
 		pci_using_dac = 1;
 	} else {
-		if((err = pci_set_dma_mask(pdev, DMA_32BIT_MASK))) {
+		if((err = pci_set_dma_mask(pdev, PCI_DMA_32BIT))) {
 			E1000_ERR("No usable DMA configuration, aborting\n");
 			return err;
 		}
