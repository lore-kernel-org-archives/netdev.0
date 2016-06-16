From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: [PATCH] net: lantiq_etop: remove unused variable
Date: Thu, 16 Jun 2016 22:19:31 +0100
Message-ID: <1466111971-3330-1-git-send-email-sudipm.mukherjee@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Sudip Mukherjee <sudipm.mukherjee@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The variable i was declared but was never used and we were getting a
build warning for that.

Signed-off-by: Sudip Mukherjee <sudip.mukherjee@codethink.co.uk>
---
 drivers/net/ethernet/lantiq_etop.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/lantiq_etop.c b/drivers/net/ethernet/lantiq_etop.c
index dc82b1b..0d2f8e9 100644
--- a/drivers/net/ethernet/lantiq_etop.c
+++ b/drivers/net/ethernet/lantiq_etop.c
@@ -411,7 +411,6 @@ static int
 ltq_etop_mdio_init(struct net_device *dev)
 {
 	struct ltq_etop_priv *priv = netdev_priv(dev);
-	int i;
 	int err;
 
 	priv->mii_bus = mdiobus_alloc();
-- 
1.9.1
