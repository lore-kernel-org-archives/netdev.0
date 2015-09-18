From: Luis de Bethencourt <luis@debethencourt.com>
Subject: [PATCH 2/2] net: phy: mdio-gpio: Fix module autoload for OF platform
 driver
Date: Fri, 18 Sep 2015 18:16:29 +0200
Message-ID: <20150918161629.GA25842@goodgumbo.baconseed.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This platform driver has a OF device ID table but the OF module
alias information is not created so module autoloading won't work.

Signed-off-by: Luis de Bethencourt <luisbg@osg.samsung.com>
---
 drivers/net/phy/mdio-gpio.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/phy/mdio-gpio.c b/drivers/net/phy/mdio-gpio.c
index 7dc21e5..3bc9f03 100644
--- a/drivers/net/phy/mdio-gpio.c
+++ b/drivers/net/phy/mdio-gpio.c
@@ -261,6 +261,7 @@ static const struct of_device_id mdio_gpio_of_match[] = {
 	{ .compatible = "virtual,mdio-gpio", },
 	{ /* sentinel */ }
 };
+MODULE_DEVICE_TABLE(of, mdio_gpio_of_match);
 
 static struct platform_driver mdio_gpio_driver = {
 	.probe = mdio_gpio_probe,
-- 
2.4.6
