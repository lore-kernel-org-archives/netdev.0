From: Grant Grundler <grundler@chromium.org>
Subject: [PATCH] r8152: add MODULE_VERSION
Date: Thu, 14 Jul 2016 11:27:16 -0700
Message-ID: <1468520836-9060-1-git-send-email-grundler@chromium.org>
Cc: Peter Wu <peter@lekensteyn.nl>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	Grant Grundler <grundler@chromium.org>
To: "David S . Miller" <davem@davemloft.net>,
	Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ethtool -i provides a driver version that is hard coded.
Export the same value via "modinfo".

Signed-off-by: Grant Grundler <grundler@chromium.org>
---
 drivers/net/usb/r8152.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 0da72d3..1c01ed5 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -4359,3 +4359,4 @@ module_usb_driver(rtl8152_driver);
 MODULE_AUTHOR(DRIVER_AUTHOR);
 MODULE_DESCRIPTION(DRIVER_DESC);
 MODULE_LICENSE("GPL");
+MODULE_VERSION(DRIVER_VERSION);
-- 
2.8.0.rc3.226.g39d4020
