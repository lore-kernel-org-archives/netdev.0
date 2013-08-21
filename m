From: Libo Chen <libo.chen@huawei.com>
Subject: [PATCH] net: irda: pxaficp_ir: use platform_set_drvdata()
Date: Wed, 21 Aug 2013 18:15:11 +0800
Message-ID: <1377080111-11348-1-git-send-email-libo.chen@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<lizefan@huawei.com>, <libo.chen@huawei.com>
To: <samuel@sortiz.org>, <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the wrapper functions for getting and setting the driver data using
platform_device instead of using deva_set_drvdata() with &pdev->dev,
so we can directly pass a struct platform_device.

Signed-off-by: Libo Chen <libo.chen@huawei.com>
---
 drivers/net/irda/pxaficp_ir.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/irda/pxaficp_ir.c b/drivers/net/irda/pxaficp_ir.c
index 964b116..3eeaaf8 100644
--- a/drivers/net/irda/pxaficp_ir.c
+++ b/drivers/net/irda/pxaficp_ir.c
@@ -915,7 +915,7 @@ static int pxa_irda_probe(struct platform_device *pdev)
 	err = register_netdev(dev);
 
 	if (err == 0)
-		dev_set_drvdata(&pdev->dev, dev);
+		platform_set_drvdata(pdev, dev);
 
 	if (err) {
 		if (si->pdata->shutdown)
-- 
1.7.1
