From: Shrikrishna Khare <skhare@vmware.com>
Subject: [PATCH net-next] Driver: Vmxnet3: Change the hex constant to its decimal equivalent
Date: Fri,  6 Feb 2015 13:48:28 -0800
Message-ID: <1423259308-4667-1-git-send-email-skhare@vmware.com>
Cc: Shrikrishna Khare <skhare@vmware.com>
To: sbhatewara@vmware.com, pv-drivers@vmware.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The hex constant chosen for VMXNET3_REV1_MAGIC is offensive,
replace it with its decimal equivalent.

Signed-off-by: Shrikrishna Khare <skhare@vmware.com>
Reviewed-by: Shreyas Bhatewara <sbhatewara@vmware.com>
---
 drivers/net/vmxnet3/vmxnet3_defs.h |    2 +-
 drivers/net/vmxnet3/vmxnet3_int.h  |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_defs.h b/drivers/net/vmxnet3/vmxnet3_defs.h
index 25b6fa4..3718d02 100644
--- a/drivers/net/vmxnet3/vmxnet3_defs.h
+++ b/drivers/net/vmxnet3/vmxnet3_defs.h
@@ -393,7 +393,7 @@ struct Vmxnet3_DriverInfo {
 };
 
 
-#define VMXNET3_REV1_MAGIC  0xbabefee1
+#define VMXNET3_REV1_MAGIC  3133079265u
 
 /*
  * QueueDescPA must be 128 bytes aligned. It points to an array of
diff --git a/drivers/net/vmxnet3/vmxnet3_int.h b/drivers/net/vmxnet3/vmxnet3_int.h
index 406144b..cd71c77 100644
--- a/drivers/net/vmxnet3/vmxnet3_int.h
+++ b/drivers/net/vmxnet3/vmxnet3_int.h
@@ -69,10 +69,10 @@
 /*
  * Version numbers
  */
-#define VMXNET3_DRIVER_VERSION_STRING   "1.3.3.0-k"
+#define VMXNET3_DRIVER_VERSION_STRING   "1.3.4.0-k"
 
 /* a 32-bit int, each byte encode a verion number in VMXNET3_DRIVER_VERSION */
-#define VMXNET3_DRIVER_VERSION_NUM      0x01030300
+#define VMXNET3_DRIVER_VERSION_NUM      0x01030400
 
 #if defined(CONFIG_PCI_MSI)
 	/* RSS only makes sense if MSI-X is supported. */
-- 
1.7.4.1
