From: Dirk Eibach <eibach@gdsys.de>
Subject: [PATCH] net: Fix driver name for mdio-gpio.c
Date: Tue, 18 Oct 2011 15:04:11 +0200
Message-ID: <1318943051-22432-1-git-send-email-eibach@gdsys.de>
Cc: netdev@vger.kernel.org, grant.likely@secretlab.ca,
	Dirk Eibach <eibach@gdsys.de>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since commit
"7488876... dt/net: Eliminate users of of_platform_{,un}register_driver"
there are two platform drivers named "mdio-gpio" registered.
I renamed the of variant to "mdio-ofgpio".

Signed-off-by: Dirk Eibach <eibach@gdsys.de>
---
 drivers/net/phy/mdio-gpio.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/phy/mdio-gpio.c b/drivers/net/phy/mdio-gpio.c
index f2d122f..3d66d9f 100644
--- a/drivers/net/phy/mdio-gpio.c
+++ b/drivers/net/phy/mdio-gpio.c
@@ -241,7 +241,7 @@ MODULE_DEVICE_TABLE(of, mdio_ofgpio_match);
 
 static struct platform_driver mdio_ofgpio_driver = {
 	.driver = {
-		.name = "mdio-gpio",
+		.name = "mdio-ofgpio",
 		.owner = THIS_MODULE,
 		.of_match_table = mdio_ofgpio_match,
 	},
-- 
1.5.6.5
