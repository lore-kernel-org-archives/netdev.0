From: Masanari Iida <standby24x7@gmail.com>
Subject: [PATCH] [trivial] treewide: Fix company name in module descriptions
Date: Fri, 17 Oct 2014 00:09:24 +0900
Message-ID: <1413472164-22366-1-git-send-email-standby24x7@gmail.com>
Cc: netdev@vger.kernel.org, Masanari Iida <standby24x7@gmail.com>
To: linux-kernel@vger.kernel.org, mturquette@linaro.org,
	trivial@kernel.org, linus.walleij@linaro.org, gnurou@gmail.com,
	jcliburn@gmail.com, chris.snook@gmail.com, viresh.linux@gmail.com,
	inki.dae@samsung.com, dh09.lee@samsung.com, kgene.kim@samsung.com,
	rdunlap@infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fix company name's spelling typo in module descriptions
and a Kconfig.

Signed-off-by: Masanari Iida <standby24x7@gmail.com>
---
 drivers/clk/Kconfig                                 | 2 +-
 drivers/gpio/gpio-spear-spics.c                     | 2 +-
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c     | 2 +-
 drivers/pinctrl/spear/pinctrl-plgpio.c              | 2 +-
 drivers/video/fbdev/exynos/exynos_mipi_dsi.c        | 2 +-
 drivers/video/fbdev/exynos/exynos_mipi_dsi_common.c | 2 +-
 6 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/clk/Kconfig b/drivers/clk/Kconfig
index 455fd17..3f44f29 100644
--- a/drivers/clk/Kconfig
+++ b/drivers/clk/Kconfig
@@ -28,7 +28,7 @@ config COMMON_CLK_WM831X
 	depends on MFD_WM831X
 	---help---
           Supports the clocking subsystem of the WM831x/2x series of
-	  PMICs from Wolfson Microlectronics.
+	  PMICs from Wolfson Microelectronics.
 
 source "drivers/clk/versatile/Kconfig"
 
diff --git a/drivers/gpio/gpio-spear-spics.c b/drivers/gpio/gpio-spear-spics.c
index 353263c..506a2ea 100644
--- a/drivers/gpio/gpio-spear-spics.c
+++ b/drivers/gpio/gpio-spear-spics.c
@@ -204,5 +204,5 @@ static int __init spics_gpio_init(void)
 subsys_initcall(spics_gpio_init);
 
 MODULE_AUTHOR("Shiraz Hashim <shiraz.linux.kernel@gmail.com>");
-MODULE_DESCRIPTION("ST Microlectronics SPEAr SPI Chip Select Abstraction");
+MODULE_DESCRIPTION("STMicroelectronics SPEAr SPI Chip Select Abstraction");
 MODULE_LICENSE("GPL");
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 72fb86b..c9946c6 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -48,7 +48,7 @@ MODULE_DEVICE_TABLE(pci, atl1c_pci_tbl);
 
 MODULE_AUTHOR("Jie Yang");
 MODULE_AUTHOR("Qualcomm Atheros Inc., <nic-devel@qualcomm.com>");
-MODULE_DESCRIPTION("Qualcom Atheros 100/1000M Ethernet Network Driver");
+MODULE_DESCRIPTION("Qualcomm Atheros 100/1000M Ethernet Network Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(ATL1C_DRV_VERSION);
 
diff --git a/drivers/pinctrl/spear/pinctrl-plgpio.c b/drivers/pinctrl/spear/pinctrl-plgpio.c
index bddb791..ce5f22c 100644
--- a/drivers/pinctrl/spear/pinctrl-plgpio.c
+++ b/drivers/pinctrl/spear/pinctrl-plgpio.c
@@ -724,5 +724,5 @@ static int __init plgpio_init(void)
 subsys_initcall(plgpio_init);
 
 MODULE_AUTHOR("Viresh Kumar <viresh.kumar@linaro.org>");
-MODULE_DESCRIPTION("ST Microlectronics SPEAr PLGPIO driver");
+MODULE_DESCRIPTION("STMicroelectronics SPEAr PLGPIO driver");
 MODULE_LICENSE("GPL");
diff --git a/drivers/video/fbdev/exynos/exynos_mipi_dsi.c b/drivers/video/fbdev/exynos/exynos_mipi_dsi.c
index cee9602..716bfad 100644
--- a/drivers/video/fbdev/exynos/exynos_mipi_dsi.c
+++ b/drivers/video/fbdev/exynos/exynos_mipi_dsi.c
@@ -570,5 +570,5 @@ static struct platform_driver exynos_mipi_dsi_driver = {
 module_platform_driver(exynos_mipi_dsi_driver);
 
 MODULE_AUTHOR("InKi Dae <inki.dae@samsung.com>");
-MODULE_DESCRIPTION("Samusung SoC MIPI-DSI driver");
+MODULE_DESCRIPTION("Samsung SoC MIPI-DSI driver");
 MODULE_LICENSE("GPL");
diff --git a/drivers/video/fbdev/exynos/exynos_mipi_dsi_common.c b/drivers/video/fbdev/exynos/exynos_mipi_dsi_common.c
index 85edabf..2358a2f 100644
--- a/drivers/video/fbdev/exynos/exynos_mipi_dsi_common.c
+++ b/drivers/video/fbdev/exynos/exynos_mipi_dsi_common.c
@@ -876,5 +876,5 @@ int exynos_mipi_dsi_fifo_clear(struct mipi_dsim_device *dsim,
 }
 
 MODULE_AUTHOR("InKi Dae <inki.dae@samsung.com>");
-MODULE_DESCRIPTION("Samusung SoC MIPI-DSI common driver");
+MODULE_DESCRIPTION("Samsung SoC MIPI-DSI common driver");
 MODULE_LICENSE("GPL");
-- 
2.1.2.443.g670a3c1
