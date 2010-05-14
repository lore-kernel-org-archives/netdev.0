From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [patch 2.6.35 25/25] wimax/i2400m: driver defaults to firmware v1.5 for i6x60 devices
Date: Fri, 14 May 2010 14:45:24 -0700
Message-ID: <0fb0a4f00aaf5de9f328273d7a46e3aa27dab496.1273708027.git.inaky.perez-gonzalez@intel.com>
References: <cover.1273708027.git.inaky.perez-gonzalez@intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:17451 "EHLO
	fmsmga101.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932456Ab0ENVtW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 May 2010 17:49:22 -0400
In-Reply-To: <cover.1273708027.git.inaky.perez-gonzalez@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Firmware is available in the linux-firmware package.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/usb.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wimax/i2400m/usb.c b/drivers/net/wimax/i2400m/usb.c
index f456807..16341ff 100644
--- a/drivers/net/wimax/i2400m/usb.c
+++ b/drivers/net/wimax/i2400m/usb.c
@@ -788,3 +788,4 @@ MODULE_DESCRIPTION("Driver for USB based Intel Wireless WiMAX Connection 2400M "
 		   "(5x50 & 6050)");
 MODULE_LICENSE("GPL");
 MODULE_FIRMWARE(I2400MU_FW_FILE_NAME_v1_5);
+MODULE_FIRMWARE(I6050U_FW_FILE_NAME_v1_5);
-- 
1.6.6.1

