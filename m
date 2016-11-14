From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] mdio: Demote print from info to debug in mdio_driver_register
Date: Sun, 13 Nov 2016 19:01:17 -0800
Message-ID: <20161114030117.25169-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f194.google.com ([209.85.161.194]:35324 "EHLO
        mail-yw0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752106AbcKNDBY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 13 Nov 2016 22:01:24 -0500
Received: by mail-yw0-f194.google.com with SMTP id b66so5055245ywh.2
        for <netdev@vger.kernel.org>; Sun, 13 Nov 2016 19:01:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While it is useful to know which MDIO driver is being registered, demote
the pr_info() to a pr_debug().

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/mdio_device.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/mdio_device.c b/drivers/net/phy/mdio_device.c
index 9c88e6749b9a..43c8fd46504b 100644
--- a/drivers/net/phy/mdio_device.c
+++ b/drivers/net/phy/mdio_device.c
@@ -144,7 +144,7 @@ int mdio_driver_register(struct mdio_driver *drv)
 	struct mdio_driver_common *mdiodrv = &drv->mdiodrv;
 	int retval;
 
-	pr_info("mdio_driver_register: %s\n", mdiodrv->driver.name);
+	pr_debug("mdio_driver_register: %s\n", mdiodrv->driver.name);
 
 	mdiodrv->driver.bus = &mdio_bus_type;
 	mdiodrv->driver.probe = mdio_probe;
-- 
2.9.3
