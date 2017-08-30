From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH 1/5] net: mdio-mux: Fix NULL Comparison style
Date: Wed, 30 Aug 2017 19:46:47 +0200
Message-ID: <20170830174651.30325-2-clabbe.montjoie@gmail.com>
References: <20170830174651.30325-1-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: andrew@lunn.ch, f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170830174651.30325-1-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fix checkpatch warning about NULL Comparison style.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 drivers/net/phy/mdio-mux.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/mdio-mux.c b/drivers/net/phy/mdio-mux.c
index 942ceaf3fd3f..b18ad7082b88 100644
--- a/drivers/net/phy/mdio-mux.c
+++ b/drivers/net/phy/mdio-mux.c
@@ -120,7 +120,7 @@ int mdio_mux_init(struct device *dev,
 	}
 
 	pb = devm_kzalloc(dev, sizeof(*pb), GFP_KERNEL);
-	if (pb == NULL) {
+	if (!pb) {
 		ret_val = -ENOMEM;
 		goto err_pb_kz;
 	}
@@ -144,7 +144,7 @@ int mdio_mux_init(struct device *dev,
 		}
 
 		cb = devm_kzalloc(dev, sizeof(*cb), GFP_KERNEL);
-		if (cb == NULL) {
+		if (!cb) {
 			dev_err(dev,
 				"Error: Failed to allocate memory for child %pOF\n",
 				child_bus_node);
-- 
2.13.5
