From: Libo Chen <libo.chen@huawei.com>
Subject: [PATCH 1/8] net: fsl_pq_mdio: remove unnecessary dev_set_drvdata()
Date: Wed, 21 Aug 2013 15:02:13 +0800
Message-ID: <1377068533-53208-1-git-send-email-libo.chen@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <timur@freescale.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <lizefan@huawei.com>,
	<libo.chen@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Unnecessary dev_set_drvdata() is removed, because the driver core
clears the driver data to NULL after device_release or on probe failure.

Signed-off-by: Libo Chen <libo.chen@huawei.com>
---
 drivers/net/ethernet/freescale/fsl_pq_mdio.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fsl_pq_mdio.c b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
index b7dcd41..c4f6506 100644
--- a/drivers/net/ethernet/freescale/fsl_pq_mdio.c
+++ b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
@@ -468,8 +468,6 @@ static int fsl_pq_mdio_remove(struct platform_device *pdev)
 
 	mdiobus_unregister(bus);
 
-	dev_set_drvdata(device, NULL);
-
 	iounmap(priv->map);
 	mdiobus_free(bus);
 
-- 
1.7.1
