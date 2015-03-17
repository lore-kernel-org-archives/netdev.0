From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 11/16 linux-next] net: phy: constify of_device_id array
Date: Tue, 17 Mar 2015 19:40:23 +0100
Message-ID: <1426617628-937-2-git-send-email-fabf@skynet.be>
References: <1426617469-781-1-git-send-email-fabf@skynet.be>
 <1426617628-937-1-git-send-email-fabf@skynet.be>
Cc: davem@davemloft.net, Fabian Frederick <fabf@skynet.be>,
	Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1426617628-937-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

of_device_id is always used as const.
(See driver.of_match_table and open firmware functions)

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 drivers/net/phy/mdio-bcm-unimac.c  | 2 +-
 drivers/net/phy/mdio-gpio.c        | 2 +-
 drivers/net/phy/mdio-mux-gpio.c    | 2 +-
 drivers/net/phy/mdio-mux-mmioreg.c | 2 +-
 drivers/net/phy/mdio-octeon.c      | 2 +-
 5 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/phy/mdio-bcm-unimac.c b/drivers/net/phy/mdio-bcm-unimac.c
index 6deac6d..414fdf1 100644
--- a/drivers/net/phy/mdio-bcm-unimac.c
+++ b/drivers/net/phy/mdio-bcm-unimac.c
@@ -187,7 +187,7 @@ static int unimac_mdio_remove(struct platform_device *pdev)
 	return 0;
 }
 
-static struct of_device_id unimac_mdio_ids[] = {
+static const struct of_device_id unimac_mdio_ids[] = {
 	{ .compatible = "brcm,genet-mdio-v4", },
 	{ .compatible = "brcm,genet-mdio-v3", },
 	{ .compatible = "brcm,genet-mdio-v2", },
diff --git a/drivers/net/phy/mdio-gpio.c b/drivers/net/phy/mdio-gpio.c
index 0a0578a..49ce7ec 100644
--- a/drivers/net/phy/mdio-gpio.c
+++ b/drivers/net/phy/mdio-gpio.c
@@ -249,7 +249,7 @@ static int mdio_gpio_remove(struct platform_device *pdev)
 	return 0;
 }
 
-static struct of_device_id mdio_gpio_of_match[] = {
+static const struct of_device_id mdio_gpio_of_match[] = {
 	{ .compatible = "virtual,mdio-gpio", },
 	{ /* sentinel */ }
 };
diff --git a/drivers/net/phy/mdio-mux-gpio.c b/drivers/net/phy/mdio-mux-gpio.c
index 320eb15..1a87a58 100644
--- a/drivers/net/phy/mdio-mux-gpio.c
+++ b/drivers/net/phy/mdio-mux-gpio.c
@@ -99,7 +99,7 @@ static int mdio_mux_gpio_remove(struct platform_device *pdev)
 	return 0;
 }
 
-static struct of_device_id mdio_mux_gpio_match[] = {
+static const struct of_device_id mdio_mux_gpio_match[] = {
 	{
 		.compatible = "mdio-mux-gpio",
 	},
diff --git a/drivers/net/phy/mdio-mux-mmioreg.c b/drivers/net/phy/mdio-mux-mmioreg.c
index 0aa985c..2377c13 100644
--- a/drivers/net/phy/mdio-mux-mmioreg.c
+++ b/drivers/net/phy/mdio-mux-mmioreg.c
@@ -145,7 +145,7 @@ static int mdio_mux_mmioreg_remove(struct platform_device *pdev)
 	return 0;
 }
 
-static struct of_device_id mdio_mux_mmioreg_match[] = {
+static const struct of_device_id mdio_mux_mmioreg_match[] = {
 	{
 		.compatible = "mdio-mux-mmioreg",
 	},
diff --git a/drivers/net/phy/mdio-octeon.c b/drivers/net/phy/mdio-octeon.c
index c810524..c838ad6 100644
--- a/drivers/net/phy/mdio-octeon.c
+++ b/drivers/net/phy/mdio-octeon.c
@@ -252,7 +252,7 @@ static int octeon_mdiobus_remove(struct platform_device *pdev)
 	return 0;
 }
 
-static struct of_device_id octeon_mdiobus_match[] = {
+static const struct of_device_id octeon_mdiobus_match[] = {
 	{
 		.compatible = "cavium,octeon-3860-mdio",
 	},
-- 
2.1.0
