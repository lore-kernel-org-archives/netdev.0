From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v2 2/5] net: mdio-mux: Remove unnecessary 'out of memory' message
Date: Fri,  1 Sep 2017 13:56:01 +0200
Message-ID: <20170901115604.27513-3-clabbe.montjoie@gmail.com>
References: <20170901115604.27513-1-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: andrew@lunn.ch, f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33212 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751956AbdIAL6Q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 07:58:16 -0400
In-Reply-To: <20170901115604.27513-1-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fix checkpatch warning about unnecessary 'out of memory'
message.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/phy/mdio-mux.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/net/phy/mdio-mux.c b/drivers/net/phy/mdio-mux.c
index b18ad7082b88..5e08e89465c5 100644
--- a/drivers/net/phy/mdio-mux.c
+++ b/drivers/net/phy/mdio-mux.c
@@ -145,9 +145,6 @@ int mdio_mux_init(struct device *dev,
 
 		cb = devm_kzalloc(dev, sizeof(*cb), GFP_KERNEL);
 		if (!cb) {
-			dev_err(dev,
-				"Error: Failed to allocate memory for child %pOF\n",
-				child_bus_node);
 			ret_val = -ENOMEM;
 			continue;
 		}
@@ -156,9 +153,6 @@ int mdio_mux_init(struct device *dev,
 
 		cb->mii_bus = mdiobus_alloc();
 		if (!cb->mii_bus) {
-			dev_err(dev,
-				"Error: Failed to allocate MDIO bus for child %pOF\n",
-				child_bus_node);
 			ret_val = -ENOMEM;
 			devm_kfree(dev, cb);
 			continue;
-- 
2.13.5
