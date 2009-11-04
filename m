From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/1 07/12] wimax/i2400m: Update comments to talk about SDIO reset and not USB.
Date: Wed,  4 Nov 2009 13:39:43 -0800
Message-ID: <81b182a7542c4282191fa0b1e8d9fcb022c03e68.1257370735.git.inaky@linux.intel.com>
References: <cover.1257370735.git.inaky@linux.intel.com>
Cc: Dirk Brandewie <dirk.j.brandewie@intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:31748 "EHLO
	fmsmga101.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758263AbZKDVlx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:41:53 -0500
In-Reply-To: <cover.1257370735.git.inaky@linux.intel.com>
In-Reply-To: <cover.1257370735.git.inaky@linux.intel.com>
References: <cover.1257370735.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dirk Brandewie <dirk.j.brandewie@intel.com>

Fixing comments from original cut and paste error

Signed-off-by: Dirk Brandewie <dirk.j.brandewie@intel.com>
Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/sdio.c |   13 ++++++-------
 1 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/drivers/net/wimax/i2400m/sdio.c b/drivers/net/wimax/i2400m/sdio.c
index 2981e21..c67b026 100644
--- a/drivers/net/wimax/i2400m/sdio.c
+++ b/drivers/net/wimax/i2400m/sdio.c
@@ -233,18 +233,17 @@ error_kzalloc:
  * Warm reset:
  *
  * The device will be fully reset internally, but won't be
- * disconnected from the USB bus (so no reenumeration will
+ * disconnected from the bus (so no reenumeration will
  * happen). Firmware upload will be neccessary.
  *
- * The device will send a reboot barker in the notification endpoint
- * that will trigger the driver to reinitialize the state
- * automatically from notif.c:i2400m_notification_grok() into
- * i2400m_dev_bootstrap_delayed().
+ * The device will send a reboot barker that will trigger the driver
+ * to reinitialize the state via __i2400m_dev_reset_handle.
  *
- * Cold and bus (USB) reset:
+ *
+ * Cold and bus reset:
  *
  * The device will be fully reset internally, disconnected from the
- * USB bus an a reenumeration will happen. Firmware upload will be
+ * bus an a reenumeration will happen. Firmware upload will be
  * neccessary. Thus, we don't do any locking or struct
  * reinitialization, as we are going to be fully disconnected and
  * reenumerated.
-- 
1.6.2.5

