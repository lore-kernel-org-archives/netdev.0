From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/3 01/13] wimax/iwmc3200: add new sdio device ID to support iwmc3200 2.5GHz sku
Date: Wed,  4 Nov 2009 13:39:52 -0800
Message-ID: <f8fc3295570115267ce1ce901f362d13d194aefc.1257370736.git.inaky@linux.intel.com>
References: <cover.1257370736.git.inaky@linux.intel.com>
Cc: Cindy H Kao <cindy.h.kao@intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:20707 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932727AbZKDVmE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:42:04 -0500
In-Reply-To: <cover.1257370736.git.inaky@linux.intel.com>
In-Reply-To: <cover.1257370736.git.inaky@linux.intel.com>
References: <cover.1257370736.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cindy H Kao <cindy.h.kao@intel.com>

Different sdio device IDs are designated to support different intel
wimax silicon sku. The new macro SDIO_DEVICE_ID_IWMC3200_WIMAX_2G5(0x1407)
is added to support iwmc3200 2.5GHz sku.  The existing
SDIO_DEVICE_ID_IWMC3200_WIMAX(0x1402) is for iwmc3200 general sku.

Signed-off-by: Cindy H Kao <cindy.h.kao@intel.com>
Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/sdio.c |    2 ++
 include/linux/mmc/sdio_ids.h    |    1 +
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wimax/i2400m/sdio.c b/drivers/net/wimax/i2400m/sdio.c
index 2d2cc5a..de158ee 100644
--- a/drivers/net/wimax/i2400m/sdio.c
+++ b/drivers/net/wimax/i2400m/sdio.c
@@ -550,6 +550,8 @@ const struct sdio_device_id i2400ms_sdio_ids[] = {
 	/* Intel: i2400m WiMAX (iwmc3200) over SDIO */
 	{ SDIO_DEVICE(SDIO_VENDOR_ID_INTEL,
 		      SDIO_DEVICE_ID_INTEL_IWMC3200WIMAX) },
+	{ SDIO_DEVICE(SDIO_VENDOR_ID_INTEL,
+		      SDIO_DEVICE_ID_INTEL_IWMC3200WIMAX_2G5) },
 	{ /* end: all zeroes */ },
 };
 MODULE_DEVICE_TABLE(sdio, i2400ms_sdio_ids);
diff --git a/include/linux/mmc/sdio_ids.h b/include/linux/mmc/sdio_ids.h
index 2dbfb5a..33b2ea0 100644
--- a/include/linux/mmc/sdio_ids.h
+++ b/include/linux/mmc/sdio_ids.h
@@ -28,6 +28,7 @@
 #define SDIO_DEVICE_ID_INTEL_IWMC3200TOP	0x1404
 #define SDIO_DEVICE_ID_INTEL_IWMC3200GPS	0x1405
 #define SDIO_DEVICE_ID_INTEL_IWMC3200BT		0x1406
+#define SDIO_DEVICE_ID_INTEL_IWMC3200WIMAX_2G5	0x1407
 
 #define SDIO_VENDOR_ID_MARVELL			0x02df
 #define SDIO_DEVICE_ID_MARVELL_LIBERTAS		0x9103
-- 
1.6.2.5

