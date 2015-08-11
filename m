From: sdliyong@gmail.com
Subject: [PATCH v2 bluetooth-next] cc2520: set the default fifo pin value from platform data
Date: Tue, 11 Aug 2015 10:43:05 +0800
Message-ID: <1439260985-5173-1-git-send-email-sdliyong@gmail.com>
Cc: Yong Li <sdliyong@gmail.com>
To: varkabhadram@gmail.com, alex.aring@gmail.com,
	linux-wpan@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yong Li <sdliyong@gmail.com>

When the device tree support is disabled, the fifo_pin is uninitialized,
this patch will set the fifo_pin value based on platform data

Signed-off-by: Yong Li <sdliyong@gmail.com>
---
 drivers/net/ieee802154/cc2520.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ieee802154/cc2520.c b/drivers/net/ieee802154/cc2520.c
index 613dae5..c5b54a1 100644
--- a/drivers/net/ieee802154/cc2520.c
+++ b/drivers/net/ieee802154/cc2520.c
@@ -833,6 +833,7 @@ static int cc2520_get_platform_data(struct spi_device *spi,
 		if (!spi_pdata)
 			return -ENOENT;
 		*pdata = *spi_pdata;
+		priv->fifo_pin = pdata->fifo;
 		return 0;
 	}
 
-- 
2.1.0
