From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH 2/5] net: mdio-mux: Remove unnecessary 'out of memory' message
Date: Wed, 30 Aug 2017 19:46:48 +0200
Message-ID: <20170830174651.30325-3-clabbe.montjoie@gmail.com>
References: <20170830174651.30325-1-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: andrew@lunn.ch, f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170830174651.30325-1-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fix checkpatch warning about unnecessary 'out of memory'
message.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
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
