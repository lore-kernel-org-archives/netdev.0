From: Sebastian Reichel <sebastian.reichel@collabora.co.uk>
Subject: [PATCHv5] wlcore: add wl1285 compatible
Date: Thu,  8 Jun 2017 22:50:00 +0200
Message-ID: <20170608205000.3268-1-sebastian.reichel@collabora.co.uk>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Sebastian Reichel <sebastian.reichel@collabora.co.uk>
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Motorola Droid 4 uses a WL 1285C. With differences between
chips not being public let's add explicit binding for wl1285
instead of relying on wl1283 being very similar.

Reviewed-by: Rob Herring <robh@kernel.org>
Acked-by: Kalle Valo <kvalo@codeaurora.org>
Acked-by: Tony Lindgren <tony@atomide.com>
Signed-off-by: Sebastian Reichel <sebastian.reichel@collabora.co.uk>
---
Changes since PATCHv4:
 - Dropped droid4.dts change, patch can go in normally now
Changes since PATCHv3:
 - add netdev@vger.kernel.org to cc
 - add Acked-By from Tony & Kalle
Changes since PATCHv2:
 - merge patch for DTS and driver
 - add Acked-By from Rob
Changes since PATCHv1:
 - patches did not exist in patchv1
---
 Documentation/devicetree/bindings/net/wireless/ti,wlcore.txt | 1 +
 drivers/net/wireless/ti/wlcore/sdio.c                        | 1 +
 drivers/net/wireless/ti/wlcore/spi.c                         | 1 +
 3 files changed, 3 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/wireless/ti,wlcore.txt b/Documentation/devicetree/bindings/net/wireless/ti,wlcore.txt
index 2a3d90de18ee..7b2cbb14113e 100644
--- a/Documentation/devicetree/bindings/net/wireless/ti,wlcore.txt
+++ b/Documentation/devicetree/bindings/net/wireless/ti,wlcore.txt
@@ -10,6 +10,7 @@ Required properties:
     * "ti,wl1273"
     * "ti,wl1281"
     * "ti,wl1283"
+    * "ti,wl1285"
     * "ti,wl1801"
     * "ti,wl1805"
     * "ti,wl1807"
diff --git a/drivers/net/wireless/ti/wlcore/sdio.c b/drivers/net/wireless/ti/wlcore/sdio.c
index 287023ef4a78..2fb38717346f 100644
--- a/drivers/net/wireless/ti/wlcore/sdio.c
+++ b/drivers/net/wireless/ti/wlcore/sdio.c
@@ -237,6 +237,7 @@ static const struct of_device_id wlcore_sdio_of_match_table[] = {
 	{ .compatible = "ti,wl1273", .data = &wl127x_data },
 	{ .compatible = "ti,wl1281", .data = &wl128x_data },
 	{ .compatible = "ti,wl1283", .data = &wl128x_data },
+	{ .compatible = "ti,wl1285", .data = &wl128x_data },
 	{ .compatible = "ti,wl1801", .data = &wl18xx_data },
 	{ .compatible = "ti,wl1805", .data = &wl18xx_data },
 	{ .compatible = "ti,wl1807", .data = &wl18xx_data },
diff --git a/drivers/net/wireless/ti/wlcore/spi.c b/drivers/net/wireless/ti/wlcore/spi.c
index f949ad2bd898..1f5d9ebb0925 100644
--- a/drivers/net/wireless/ti/wlcore/spi.c
+++ b/drivers/net/wireless/ti/wlcore/spi.c
@@ -433,6 +433,7 @@ static const struct of_device_id wlcore_spi_of_match_table[] = {
 	{ .compatible = "ti,wl1273", .data = &wl127x_data},
 	{ .compatible = "ti,wl1281", .data = &wl128x_data},
 	{ .compatible = "ti,wl1283", .data = &wl128x_data},
+	{ .compatible = "ti,wl1285", .data = &wl128x_data},
 	{ .compatible = "ti,wl1801", .data = &wl18xx_data},
 	{ .compatible = "ti,wl1805", .data = &wl18xx_data},
 	{ .compatible = "ti,wl1807", .data = &wl18xx_data},
-- 
2.11.0
