From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] mdio: Demote print from info to debug in mdio_device_register
Date: Fri,  6 Jan 2017 22:27:59 -0800
Message-ID: <20170107062759.32015-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:34161 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1161360AbdAGG2C (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 7 Jan 2017 01:28:02 -0500
Received: by mail-oi0-f67.google.com with SMTP id 3so57429543oih.1
        for <netdev@vger.kernel.org>; Fri, 06 Jan 2017 22:28:02 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While it is useful to know which MDIO device is being registered, demote
the dev_info() to a dev_dbg().

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/mdio_device.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/mdio_device.c b/drivers/net/phy/mdio_device.c
index 43c8fd46504b..fc3aaaa36b1d 100644
--- a/drivers/net/phy/mdio_device.c
+++ b/drivers/net/phy/mdio_device.c
@@ -67,7 +67,7 @@ int mdio_device_register(struct mdio_device *mdiodev)
 {
 	int err;
 
-	dev_info(&mdiodev->dev, "mdio_device_register\n");
+	dev_dbg(&mdiodev->dev, "mdio_device_register\n");
 
 	err = mdiobus_register_device(mdiodev);
 	if (err)
-- 
2.9.3
