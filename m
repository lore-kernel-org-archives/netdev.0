From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [RFC PATCH 06/13] ARM64: dts: meson-gxl: Add MMC/SD/SDIO nodes
Date: Fri, 21 Oct 2016 16:40:31 +0200
Message-ID: <1477060838-14164-7-git-send-email-narmstrong@baylibre.com>
References: <1477060838-14164-1-git-send-email-narmstrong@baylibre.com>
Cc: Neil Armstrong <narmstrong@baylibre.com>,
        linux-gpio@vger.kernel.org, devicetree@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org,
        linux-amlogic@lists.infradead.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: khilman@baylibre.com, carlo@caione.org, linus.walleij@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f182.google.com ([209.85.216.182]:33466 "EHLO
        mail-qt0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934417AbcJUOk5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 10:40:57 -0400
Received: by mail-qt0-f182.google.com with SMTP id s49so89034842qta.0
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 07:40:57 -0700 (PDT)
In-Reply-To: <1477060838-14164-1-git-send-email-narmstrong@baylibre.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add MMC/SD/SDIO nodes clock attributes for Amlogic Meson GXL.

Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
---
 arch/arm64/boot/dts/amlogic/meson-gxl.dtsi | 21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff --git a/arch/arm64/boot/dts/amlogic/meson-gxl.dtsi b/arch/arm64/boot/dts/amlogic/meson-gxl.dtsi
index b45df2a..d1bf381 100644
--- a/arch/arm64/boot/dts/amlogic/meson-gxl.dtsi
+++ b/arch/arm64/boot/dts/amlogic/meson-gxl.dtsi
@@ -235,3 +235,24 @@
 &i2c_C {
 	clocks = <&clkc CLKID_I2C>;
 };
+
+&sd_emmc_a {
+	clocks = <&clkc CLKID_SD_EMMC_A>,
+		 <&xtal>,
+		 <&clkc CLKID_FCLK_DIV2>;
+	clock-names = "core", "clkin0", "clkin1";
+};
+
+&sd_emmc_b {
+	clocks = <&clkc CLKID_SD_EMMC_B>,
+		 <&xtal>,
+		 <&clkc CLKID_FCLK_DIV2>;
+       clock-names = "core", "clkin0", "clkin1";
+};
+
+&sd_emmc_c {
+	clocks = <&clkc CLKID_SD_EMMC_C>,
+		 <&xtal>,
+		 <&clkc CLKID_FCLK_DIV2>;
+	clock-names = "core", "clkin0", "clkin1";
+};
-- 
1.9.1
