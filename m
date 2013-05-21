From: Libo Chen <libo.chen@huawei.com>
Subject: [PATCH 12/19] drivers/net/ethernet/xscale: add missing platform_driver owner
Date: Tue, 21 May 2013 10:42:34 +0800
Message-ID: <1369104154-27540-1-git-send-email-libo.chen@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<linux-kernel@vger.kernel.org>, <lizefan@huawei.com>,
	<libo.chen@huawei.com>
To: <khc@pm.waw.pl>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

set the owner of platform_driver, to ensure that the
caller of driver holds a module refernece

Signed-off-by: Libo Chen <libo.chen@huawei.com>
---
 drivers/net/ethernet/xscale/ixp4xx_eth.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/xscale/ixp4xx_eth.c b/drivers/net/ethernet/xscale/ixp4xx_eth.c
index 6958a5e..2c004bb 100644
--- a/drivers/net/ethernet/xscale/ixp4xx_eth.c
+++ b/drivers/net/ethernet/xscale/ixp4xx_eth.c
@@ -1498,6 +1498,7 @@ static int eth_remove_one(struct platform_device *pdev)
 
 static struct platform_driver ixp4xx_eth_driver = {
 	.driver.name	= DRV_NAME,
+	.driver.owner	= THIS_MODULE,
 	.probe		= eth_init_one,
 	.remove		= eth_remove_one,
 };
-- 
1.7.1
