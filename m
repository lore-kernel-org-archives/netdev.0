From: Adit Ranadive <aditr@vmware.com>
Subject: [PATCH v4 01/16] vmxnet3: Move PCI Id to pci_ids.h
Date: Sun, 11 Sep 2016 21:49:11 -0700
Message-ID: <1473655766-31628-2-git-send-email-aditr@vmware.com>
References: <1473655766-31628-1-git-send-email-aditr@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Adit Ranadive <aditr@vmware.com>, <netdev@vger.kernel.org>,
        <linux-pci@vger.kernel.org>, <jhansen@vmware.com>,
        <asarwade@vmware.com>, <georgezhang@vmware.com>,
        <bryantan@vmware.com>
To: <dledford@redhat.com>, <linux-rdma@vger.kernel.org>,
        <pv-drivers@vmware.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1473655766-31628-1-git-send-email-aditr@vmware.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The VMXNet3 PCI Id will be shared with our paravirtual RDMA driver.
Moved it to the shared location in pci_ids.h.

Suggested-by: Leon Romanovsky <leon@kernel.org>
Signed-off-by: Adit Ranadive <aditr@vmware.com>
---
---
 drivers/net/vmxnet3/vmxnet3_int.h | 3 +--
 include/linux/pci_ids.h           | 1 +
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_int.h b/drivers/net/vmxnet3/vmxnet3_int.h
index 74fc030..2bd6bf8 100644
--- a/drivers/net/vmxnet3/vmxnet3_int.h
+++ b/drivers/net/vmxnet3/vmxnet3_int.h
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
