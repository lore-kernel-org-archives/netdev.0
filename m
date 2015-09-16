From: Javier Martinez Canillas <javier@osg.samsung.com>
Subject: [RESEND PATCH] net: ks8851: Export OF module alias information
Date: Wed, 16 Sep 2015 11:11:22 +0200
Message-ID: <1442394682-13801-1-git-send-email-javier@osg.samsung.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Javier Martinez Canillas <javier@osg.samsung.com>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Drivers needs to export the OF id table and this be built into
the module or udev won't have the necessary information to autoload
the driver module when the device is registered via OF.

Signed-off-by: Javier Martinez Canillas <javier@osg.samsung.com>

---

 drivers/net/ethernet/micrel/ks8851.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/micrel/ks8851.c b/drivers/net/ethernet/micrel/ks8851.c
index 66d4ab703f45..60f43ec22175 100644
--- a/drivers/net/ethernet/micrel/ks8851.c
+++ b/drivers/net/ethernet/micrel/ks8851.c
@@ -1601,6 +1601,7 @@ static const struct of_device_id ks8851_match_table[] = {
 	{ .compatible = "micrel,ks8851" },
 	{ }
 };
+MODULE_DEVICE_TABLE(of, ks8851_match_table);
 
 static struct spi_driver ks8851_driver = {
 	.driver = {
-- 
2.4.3
