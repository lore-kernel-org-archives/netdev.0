From: Peter Robinson <pbrobinson@gmail.com>
Subject: [PATCH] stmmac: make platform drivers depend on their associated SoC
Date: Wed,  1 Jun 2016 13:28:58 +0100
Message-ID: <1464784138-27103-1-git-send-email-pbrobinson@gmail.com>
Cc: Peter Robinson <pbrobinson@gmail.com>
To: George Spelvin <linux@sciencehorizons.net>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Alexandre Torgue <alexandre.torgue@st.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34520 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751150AbcFAM3Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 08:29:16 -0400
Received: by mail-wm0-f68.google.com with SMTP id n184so5781679wmn.1
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2016 05:29:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There's not much point, except compile test, enabling the stmmac
platform drivers unless their actual SoC is enabled. They're not
useful without it.

Signed-off-by: Peter Robinson <pbrobinson@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/Kconfig | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/Kconfig b/drivers/net/ethernet/stmicro/stmmac/Kconfig
index cec147d..8f06a66 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Kconfig
+++ b/drivers/net/ethernet/stmicro/stmmac/Kconfig
@@ -40,7 +40,7 @@ config DWMAC_GENERIC
 config DWMAC_IPQ806X
 	tristate "QCA IPQ806x DWMAC support"
 	default ARCH_QCOM
-	depends on OF
+	depends on OF && (ARCH_QCOM || COMPILE_TEST)
 	select MFD_SYSCON
 	help
 	  Support for QCA IPQ806X DWMAC Ethernet.
@@ -53,7 +53,7 @@ config DWMAC_IPQ806X
 config DWMAC_LPC18XX
 	tristate "NXP LPC18xx/43xx DWMAC support"
 	default ARCH_LPC18XX
-	depends on OF
+	depends on OF && (ARCH_LPC18XX || COMPILE_TEST)
 	select MFD_SYSCON
 	---help---
 	  Support for NXP LPC18xx/43xx DWMAC Ethernet.
@@ -61,7 +61,7 @@ config DWMAC_LPC18XX
 config DWMAC_MESON
 	tristate "Amlogic Meson dwmac support"
 	default ARCH_MESON
-	depends on OF
+	depends on OF && (ARCH_MESON || COMPILE_TEST)
 	help
 	  Support for Ethernet controller on Amlogic Meson SoCs.
 
@@ -72,7 +72,7 @@ config DWMAC_MESON
 config DWMAC_ROCKCHIP
 	tristate "Rockchip dwmac support"
 	default ARCH_ROCKCHIP
-	depends on OF
+	depends on OF && (ARCH_ROCKCHIP || COMPILE_TEST)
 	select MFD_SYSCON
 	help
 	  Support for Ethernet controller on Rockchip RK3288 SoC.
@@ -83,7 +83,7 @@ config DWMAC_ROCKCHIP
 config DWMAC_SOCFPGA
 	tristate "SOCFPGA dwmac support"
 	default ARCH_SOCFPGA
-	depends on OF
+	depends on OF && (ARCH_SOCFPGA || COMPILE_TEST)
 	select MFD_SYSCON
 	help
 	  Support for ethernet controller on Altera SOCFPGA
@@ -95,7 +95,7 @@ config DWMAC_SOCFPGA
 config DWMAC_STI
 	tristate "STi GMAC support"
 	default ARCH_STI
-	depends on OF
+	depends on OF && (ARCH_STI || COMPILE_TEST)
 	select MFD_SYSCON
 	---help---
 	  Support for ethernet controller on STi SOCs.
@@ -107,7 +107,7 @@ config DWMAC_STI
 config DWMAC_SUNXI
 	tristate "Allwinner GMAC support"
 	default ARCH_SUNXI
-	depends on OF
+	depends on OF && (ARCH_SUNXI || COMPILE_TEST)
 	---help---
 	  Support for Allwinner A20/A31 GMAC ethernet controllers.
 
-- 
2.7.4
