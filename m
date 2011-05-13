From: Felipe Balbi <balbi@ti.com>
Subject: [RFC/PATCH 01/13] net: wl12xx: sdio: id_tables should be __devinitconst
Date: Sat, 14 May 2011 00:26:18 +0300
Message-ID: <1305321990-22041-2-git-send-email-balbi@ti.com>
References: <1305321990-22041-1-git-send-email-balbi@ti.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Felipe Balbi <balbi@ti.com>
To: Luciano Coelho <coelho@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1305321990-22041-1-git-send-email-balbi@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

That's only needed during init anyway, let's free
some space after we're done probing.

Signed-off-by: Felipe Balbi <balbi@ti.com>
---
 drivers/net/wireless/wl12xx/sdio.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/wl12xx/sdio.c b/drivers/net/wireless/wl12xx/sdio.c
index b1c7d03..1268efe 100644
--- a/drivers/net/wireless/wl12xx/sdio.c
+++ b/drivers/net/wireless/wl12xx/sdio.c
@@ -45,7 +45,7 @@
 #define SDIO_DEVICE_ID_TI_WL1271	0x4076
 #endif
 
-static const struct sdio_device_id wl1271_devices[] = {
+static const struct sdio_device_id wl1271_devices[] __devinitconst = {
 	{ SDIO_DEVICE(SDIO_VENDOR_ID_TI, SDIO_DEVICE_ID_TI_WL1271) },
 	{}
 };
-- 
1.7.4.1.343.ga91df
