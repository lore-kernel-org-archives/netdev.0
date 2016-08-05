From: Adit Ranadive <aditr@vmware.com>
Subject: [PATCH] vmxnet3: Move PCI Id to pci_ids.h
Date: Fri, 5 Aug 2016 11:00:39 -0700
Message-ID: <1470420039-23125-1-git-send-email-aditr@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Adit Ranadive <aditr@vmware.com>, <leon@kernel.org>
To: <skhare@vmware.com>, <bhelgaas@google.com>,
	<pv-drivers@vmware.com>, <linux-pci@vger.kernel.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <linux-pci-owner@vger.kernel.org>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The VMXNet3 PCI Id will be shared with our upcoming paravirtual RDMA
driver. Moved it to the shared location in pci_ids.h and updated the
driver version.

Suggested-by: Leon Romanovsky <leon@kernel.org>
Signed-off-by: Adit Ranadive <aditr@vmware.com>
---
 drivers/net/vmxnet3/vmxnet3_int.h | 7 +++----
 include/linux/pci_ids.h           | 1 +
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_int.h b/drivers/net/vmxnet3/vmxnet3_int.h
index 74fc030..be5991e 100644
--- a/drivers/net/vmxnet3/vmxnet3_int.h
+++ b/drivers/net/vmxnet3/vmxnet3_int.h
@@ -69,10 +69,10 @@
 /*
  * Version numbers
  */
-#define VMXNET3_DRIVER_VERSION_STRING   "1.4.9.0-k"
+#define VMXNET3_DRIVER_VERSION_STRING   "1.4.10.0-k"
 
 /* a 32-bit int, each byte encode a verion number in VMXNET3_DRIVER_VERSION */
-#define VMXNET3_DRIVER_VERSION_NUM      0x01040900
+#define VMXNET3_DRIVER_VERSION_NUM      0x01040A00
 
 #if defined(CONFIG_PCI_MSI)
 	/* RSS only makes sense if MSI-X is supported. */
@@ -119,9 +119,8 @@ enum {
 };
 
 /*
- * PCI vendor and device IDs.
+ * Maximum devices supported.
  */
-#define PCI_DEVICE_ID_VMWARE_VMXNET3    0x07B0
 #define MAX_ETHERNET_CARDS		10
 #define MAX_PCI_PASSTHRU_DEVICE		6
 
diff --git a/include/linux/pci_ids.h b/include/linux/pci_ids.h
index c58752f..98bb455 100644
--- a/include/linux/pci_ids.h
+++ b/include/linux/pci_ids.h
@@ -2251,6 +2251,7 @@
 #define PCI_DEVICE_ID_RASTEL_2PORT	0x2000
 
 #define PCI_VENDOR_ID_VMWARE		0x15ad
+#define PCI_DEVICE_ID_VMWARE_VMXNET3	0x07b0
 
 #define PCI_VENDOR_ID_ZOLTRIX		0x15b0
 #define PCI_DEVICE_ID_ZOLTRIX_2BD0	0x2bd0
-- 
2.7.4
