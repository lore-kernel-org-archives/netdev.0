From: Bill Pemberton <wfp5p@virginia.edu>
Subject: [PATCH 201/493] phy: remove use of __devinit
Date: Mon, 19 Nov 2012 13:22:30 -0500
Message-ID: <1353349642-3677-201-git-send-email-wfp5p@virginia.edu>
References: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Cc: netdev@vger.kernel.org
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from viridian.itc.Virginia.EDU ([128.143.12.139]:41313 "EHLO
	viridian.itc.virginia.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753462Ab2KSSce (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 13:32:34 -0500
In-Reply-To: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CONFIG_HOTPLUG is going away as an option so __devinit is no longer
needed.

Signed-off-by: Bill Pemberton <wfp5p@virginia.edu>
Cc: netdev@vger.kernel.org 
---
 drivers/net/phy/mdio-gpio.c        | 4 ++--
 drivers/net/phy/mdio-mux-gpio.c    | 2 +-
 drivers/net/phy/mdio-mux-mmioreg.c | 2 +-
 drivers/net/phy/mdio-octeon.c      | 2 +-
 drivers/net/phy/spi_ks8995.c       | 2 +-
 5 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/phy/mdio-gpio.c b/drivers/net/phy/mdio-gpio.c
index 8176bb1..bf30b1d 100644
--- a/drivers/net/phy/mdio-gpio.c
+++ b/drivers/net/phy/mdio-gpio.c
@@ -103,7 +103,7 @@ static struct mdiobb_ops mdio_gpio_ops = {
 	.get_mdio_data = mdio_get,
 };
 
-static struct mii_bus * __devinit mdio_gpio_bus_init(struct device *dev,
+static struct mii_bus *mdio_gpio_bus_init(struct device *dev,
 					struct mdio_gpio_platform_data *pdata,
 					int bus_id)
 {
@@ -181,7 +181,7 @@ static void __devexit mdio_gpio_bus_destroy(struct device *dev)
 	mdio_gpio_bus_deinit(dev);
 }
 
-static int __devinit mdio_gpio_probe(struct platform_device *pdev)
+static int mdio_gpio_probe(struct platform_device *pdev)
 {
 	struct mdio_gpio_platform_data *pdata;
 	struct mii_bus *new_bus;
diff --git a/drivers/net/phy/mdio-mux-gpio.c b/drivers/net/phy/mdio-mux-gpio.c
index a688bbf..23ee064 100644
--- a/drivers/net/phy/mdio-mux-gpio.c
+++ b/drivers/net/phy/mdio-mux-gpio.c
@@ -49,7 +49,7 @@ static int mdio_mux_gpio_switch_fn(int current_child, int desired_child,
 	return 0;
 }
 
-static int __devinit mdio_mux_gpio_probe(struct platform_device *pdev)
+static int mdio_mux_gpio_probe(struct platform_device *pdev)
 {
 	enum of_gpio_flags f;
 	struct mdio_mux_gpio_state *s;
diff --git a/drivers/net/phy/mdio-mux-mmioreg.c b/drivers/net/phy/mdio-mux-mmioreg.c
index 11235c4..a38951f 100644
--- a/drivers/net/phy/mdio-mux-mmioreg.c
+++ b/drivers/net/phy/mdio-mux-mmioreg.c
@@ -67,7 +67,7 @@ static int mdio_mux_mmioreg_switch_fn(int current_child, int desired_child,
 	return 0;
 }
 
-static int __devinit mdio_mux_mmioreg_probe(struct platform_device *pdev)
+static int mdio_mux_mmioreg_probe(struct platform_device *pdev)
 {
 	struct device_node *np2, *np = pdev->dev.of_node;
 	struct mdio_mux_mmioreg_state *s;
diff --git a/drivers/net/phy/mdio-octeon.c b/drivers/net/phy/mdio-octeon.c
index b201d5f..7a07985 100644
--- a/drivers/net/phy/mdio-octeon.c
+++ b/drivers/net/phy/mdio-octeon.c
@@ -96,7 +96,7 @@ static int octeon_mdiobus_write(struct mii_bus *bus, int phy_id,
 	return 0;
 }
 
-static int __devinit octeon_mdiobus_probe(struct platform_device *pdev)
+static int octeon_mdiobus_probe(struct platform_device *pdev)
 {
 	struct octeon_mdiobus *bus;
 	struct resource *res_mem;
diff --git a/drivers/net/phy/spi_ks8995.c b/drivers/net/phy/spi_ks8995.c
index eea7424..1321c99 100644
--- a/drivers/net/phy/spi_ks8995.c
+++ b/drivers/net/phy/spi_ks8995.c
@@ -264,7 +264,7 @@ static struct bin_attribute ks8995_registers_attr = {
 
 /* ------------------------------------------------------------------------ */
 
-static int __devinit ks8995_probe(struct spi_device *spi)
+static int ks8995_probe(struct spi_device *spi)
 {
 	struct ks8995_switch    *ks;
 	struct ks8995_pdata     *pdata;
-- 
1.8.0
