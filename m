From: Tomas Winkler <tomas.winkler@intel.com>
Subject: [net-next 1/2] iwmc3200top: use prefered style for the device table.
Date: Sat, 14 Nov 2009 20:36:35 +0200
Message-ID: <1258223796-8486-1-git-send-email-tomas.winkler@intel.com>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: yi.zhu@intel.com, inaky.perez-gonzalez@intel.com,
	guy.cohen@intel.com, ron.rindjunsky@intel.com,
	Tomas Winkler <tomas.winkler@intel.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-mmc@vger.kernel.org
Return-path: <linux-mmc-owner@vger.kernel.org>
Sender: linux-mmc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use device id number directly accompany with
comment rather then a #define

Signed-off-by: Tomas Winkler <tomas.winkler@intel.com>
---
 drivers/misc/iwmc3200top/main.c |   14 +++-----------
 1 files changed, 3 insertions(+), 11 deletions(-)

diff --git a/drivers/misc/iwmc3200top/main.c b/drivers/misc/iwmc3200top/main.c
index 6e4e491..a1ce97e 100644
--- a/drivers/misc/iwmc3200top/main.c
+++ b/drivers/misc/iwmc3200top/main.c
@@ -62,15 +62,6 @@ MODULE_VERSION(DRIVER_VERSION);
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR(DRIVER_COPYRIGHT);
 
-
-/* FIXME: These can be found in sdio_ids.h in newer kernels */
-#ifndef SDIO_INTEL_VENDOR_ID
-#define SDIO_INTEL_VENDOR_ID			0x0089
-#endif
-#ifndef SDIO_DEVICE_ID_INTEL_IWMC3200TOP
-#define SDIO_DEVICE_ID_INTEL_IWMC3200TOP	0x1404
-#endif
-
 /*
  * This workers main task is to wait for OP_OPR_ALIVE
  * from TOP FW until ALIVE_MSG_TIMOUT timeout is elapsed.
@@ -662,8 +653,9 @@ static void iwmct_remove(struct sdio_func *func)
 
 
 static const struct sdio_device_id iwmct_ids[] = {
-	{ SDIO_DEVICE(SDIO_INTEL_VENDOR_ID, SDIO_DEVICE_ID_INTEL_IWMC3200TOP)},
-	{ /* end: all zeroes */	},
+	/* Intel Wireless MultiCom 3200 Top Driver */
+	{ SDIO_DEVICE(SDIO_VENDOR_ID_INTEL, 0x1404)},
+	{ },	/* Terminating entry */
 };
 
 MODULE_DEVICE_TABLE(sdio, iwmct_ids);
-- 
1.6.0.6

---------------------------------------------------------------------
Intel Israel (74) Limited

This e-mail and any attachments may contain confidential material for
the sole use of the intended recipient(s). Any review or distribution
by others is strictly prohibited. If you are not the intended
recipient, please contact the sender and delete all copies.

