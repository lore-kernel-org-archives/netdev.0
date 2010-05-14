From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [patch 2.6.35 24/25] wimax/i2400m: driver defaults to firmware v1.5 for i5x50 devices
Date: Fri, 14 May 2010 14:45:23 -0700
Message-ID: <6c6706b330afbc0cb53e2af4d73022d1c1273f42.1273708027.git.inaky.perez-gonzalez@intel.com>
References: <cover.1273708027.git.inaky.perez-gonzalez@intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:30552 "EHLO
	fmsmga101.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932569Ab0ENVtV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 May 2010 17:49:21 -0400
In-Reply-To: <cover.1273708027.git.inaky.perez-gonzalez@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Updates the i2400m driver to default to firmware versions v1.5 for the
Intel Wireless WiMAX Connection 5150 and 5350 devices.

Firmware available in linux-firmware.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/usb.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wimax/i2400m/usb.c b/drivers/net/wimax/i2400m/usb.c
index 6fd8cf5..f456807 100644
--- a/drivers/net/wimax/i2400m/usb.c
+++ b/drivers/net/wimax/i2400m/usb.c
@@ -82,6 +82,8 @@ MODULE_PARM_DESC(debug,
 
 /* Our firmware file name */
 static const char *i2400mu_bus_fw_names_5x50[] = {
+#define I2400MU_FW_FILE_NAME_v1_5 "i2400m-fw-usb-1.5.sbcf"
+	I2400MU_FW_FILE_NAME_v1_5,
 #define I2400MU_FW_FILE_NAME_v1_4 "i2400m-fw-usb-1.4.sbcf"
 	I2400MU_FW_FILE_NAME_v1_4,
 	NULL,
@@ -785,4 +787,4 @@ MODULE_AUTHOR("Intel Corporation <linux-wimax@intel.com>");
 MODULE_DESCRIPTION("Driver for USB based Intel Wireless WiMAX Connection 2400M "
 		   "(5x50 & 6050)");
 MODULE_LICENSE("GPL");
-MODULE_FIRMWARE(I2400MU_FW_FILE_NAME_v1_4);
+MODULE_FIRMWARE(I2400MU_FW_FILE_NAME_v1_5);
-- 
1.6.6.1

