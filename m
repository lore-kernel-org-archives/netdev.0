From: Bill Pemberton <wfp5p@virginia.edu>
Subject: [PATCH 084/493] phy: remove use of __devexit_p
Date: Mon, 19 Nov 2012 13:20:33 -0500
Message-ID: <1353349642-3677-84-git-send-email-wfp5p@virginia.edu>
References: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Cc: netdev@vger.kernel.org
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from viridian.itc.Virginia.EDU ([128.143.12.139]:41655 "EHLO
	viridian.itc.virginia.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754502Ab2KSSiF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 13:38:05 -0500
In-Reply-To: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CONFIG_HOTPLUG is going away as an option so __devexit_p is no longer
needed.

Signed-off-by: Bill Pemberton <wfp5p@virginia.edu>
Cc: netdev@vger.kernel.org 
---
 drivers/net/phy/mdio-gpio.c        | 2 +-
 drivers/net/phy/mdio-mux-gpio.c    | 2 +-
 drivers/net/phy/mdio-mux-mmioreg.c | 2 +-
 drivers/net/phy/mdio-octeon.c      | 2 +-
 drivers/net/phy/spi_ks8995.c       | 2 +-
 5 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/phy/mdio-gpio.c b/drivers/net/phy/mdio-gpio.c
index 899274f..8176bb1 100644
--- a/drivers/net/phy/mdio-gpio.c
+++ b/drivers/net/phy/mdio-gpio.c
@@ -224,7 +224,7 @@ static struct of_device_id mdio_gpio_of_match[] = {
 
 static struct platform_driver mdio_gpio_driver = {
 	.probe = mdio_gpio_probe,
-	.remove = __devexit_p(mdio_gpio_remove),
+	.remove = mdio_gpio_remove,
 	.driver		= {
 		.name	= "mdio-gpio",
 		.owner	= THIS_MODULE,
diff --git a/drivers/net/phy/mdio-mux-gpio.c b/drivers/net/phy/mdio-mux-gpio.c
index eefe49e..a688bbf 100644
--- a/drivers/net/phy/mdio-mux-gpio.c
+++ b/drivers/net/phy/mdio-mux-gpio.c
@@ -130,7 +130,7 @@ static struct platform_driver mdio_mux_gpio_driver = {
 		.of_match_table = mdio_mux_gpio_match,
 	},
 	.probe		= mdio_mux_gpio_probe,
-	.remove		= __devexit_p(mdio_mux_gpio_remove),
+	.remove		= mdio_mux_gpio_remove,
 };
 
 module_platform_driver(mdio_mux_gpio_driver);
diff --git a/drivers/net/phy/mdio-mux-mmioreg.c b/drivers/net/phy/mdio-mux-mmioreg.c
index 9061ba6..11235c4 100644
--- a/drivers/net/phy/mdio-mux-mmioreg.c
+++ b/drivers/net/phy/mdio-mux-mmioreg.c
@@ -161,7 +161,7 @@ static struct platform_driver mdio_mux_mmioreg_driver = {
 		.of_match_table = mdio_mux_mmioreg_match,
 	},
 	.probe		= mdio_mux_mmioreg_probe,
-	.remove		= __devexit_p(mdio_mux_mmioreg_remove),
+	.remove		= mdio_mux_mmioreg_remove,
 };
 
 module_platform_driver(mdio_mux_mmioreg_driver);
diff --git a/drivers/net/phy/mdio-octeon.c b/drivers/net/phy/mdio-octeon.c
index d4015aa..b201d5f 100644
--- a/drivers/net/phy/mdio-octeon.c
+++ b/drivers/net/phy/mdio-octeon.c
@@ -188,7 +188,7 @@ static struct platform_driver octeon_mdiobus_driver = {
 		.of_match_table = octeon_mdiobus_match,
 	},
 	.probe		= octeon_mdiobus_probe,
-	.remove		= __devexit_p(octeon_mdiobus_remove),
+	.remove		= octeon_mdiobus_remove,
 };
 
 void octeon_mdiobus_force_mod_depencency(void)
diff --git a/drivers/net/phy/spi_ks8995.c b/drivers/net/phy/spi_ks8995.c
index 1c3abce..eea7424 100644
--- a/drivers/net/phy/spi_ks8995.c
+++ b/drivers/net/phy/spi_ks8995.c
@@ -353,7 +353,7 @@ static struct spi_driver ks8995_driver = {
 		.owner	   = THIS_MODULE,
 	},
 	.probe	  = ks8995_probe,
-	.remove	  = __devexit_p(ks8995_remove),
+	.remove	  = ks8995_remove,
 };
 
 static int __init ks8995_init(void)
-- 
1.8.0
