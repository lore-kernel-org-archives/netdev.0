From: Javier Martinez Canillas <javier@osg.samsung.com>
Subject: [PATCH 2/2] net: encx24j600: Export missing SPI module alias information
Date: Fri, 30 Oct 2015 13:49:18 +0100
Message-ID: <1446209358-26094-3-git-send-email-javier@osg.samsung.com>
References: <1446209358-26094-1-git-send-email-javier@osg.samsung.com>
Cc: netdev@vger.kernel.org, Jon Ringle <jringle@gridpoint.com>,
	davem@davemloft.net,
	Javier Martinez Canillas <javier@osg.samsung.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1446209358-26094-1-git-send-email-javier@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The driver Kconfig symbol is tristate which means that it can be built as
a module but the module alias information is not added to the module info
so module autoload won't work since user-space won't have the information.

Signed-off-by: Javier Martinez Canillas <javier@osg.samsung.com>

---

 drivers/net/ethernet/microchip/encx24j600.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/microchip/encx24j600.c b/drivers/net/ethernet/microchip/encx24j600.c
index c2dafc1c53de..2056b719c262 100644
--- a/drivers/net/ethernet/microchip/encx24j600.c
+++ b/drivers/net/ethernet/microchip/encx24j600.c
@@ -1098,6 +1098,7 @@ static const struct spi_device_id encx24j600_spi_id_table[] = {
 	{ .name = "encx24j600" },
 	{ /* sentinel */ }
 };
+MODULE_DEVICE_TABLE(spi, encx24j600_spi_id_table);
 
 static struct spi_driver encx24j600_spi_net_driver = {
 	.driver = {
-- 
2.4.3
