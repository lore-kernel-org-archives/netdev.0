From: Shrikrishna Khare <skhare@vmware.com>
Subject: [PATCH net] Driver: Vmxnet3: Update Rx ring 2 max size
Date: Fri, 19 Feb 2016 11:19:52 -0800
Message-ID: <1455909592-7651-1-git-send-email-skhare@vmware.com>
Cc: Shrikrishna Khare <skhare@vmware.com>,
	Bhavesh Davda <bhavesh@vmware.com>
To: pv-drivers@vmware.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Device emulation supports max size of 4096.

Signed-off-by: Shrikrishna Khare <skhare@vmware.com>
Signed-off-by: Bhavesh Davda <bhavesh@vmware.com>
---
 drivers/net/vmxnet3/vmxnet3_defs.h | 2 +-
 drivers/net/vmxnet3/vmxnet3_int.h  | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_defs.h b/drivers/net/vmxnet3/vmxnet3_defs.h
index 221a530..72ba8ae 100644
--- a/drivers/net/vmxnet3/vmxnet3_defs.h
+++ b/drivers/net/vmxnet3/vmxnet3_defs.h
@@ -377,7 +377,7 @@ union Vmxnet3_GenericDesc {
 #define VMXNET3_TX_RING_MAX_SIZE   4096
 #define VMXNET3_TC_RING_MAX_SIZE   4096
 #define VMXNET3_RX_RING_MAX_SIZE   4096
-#define VMXNET3_RX_RING2_MAX_SIZE  2048
+#define VMXNET3_RX_RING2_MAX_SIZE  4096
 #define VMXNET3_RC_RING_MAX_SIZE   8192
 
 /* a list of reasons for queue stop */
diff --git a/drivers/net/vmxnet3/vmxnet3_int.h b/drivers/net/vmxnet3/vmxnet3_int.h
index bdb8a6c..729c344 100644
--- a/drivers/net/vmxnet3/vmxnet3_int.h
+++ b/drivers/net/vmxnet3/vmxnet3_int.h
@@ -69,10 +69,10 @@
 /*
  * Version numbers
  */
-#define VMXNET3_DRIVER_VERSION_STRING   "1.4.5.0-k"
+#define VMXNET3_DRIVER_VERSION_STRING   "1.4.6.0-k"
 
 /* a 32-bit int, each byte encode a verion number in VMXNET3_DRIVER_VERSION */
-#define VMXNET3_DRIVER_VERSION_NUM      0x01040500
+#define VMXNET3_DRIVER_VERSION_NUM      0x01040600
 
 #if defined(CONFIG_PCI_MSI)
 	/* RSS only makes sense if MSI-X is supported. */
-- 
1.8.5.6
