From: Libo Chen <libo.chen@huawei.com>
Subject: [PATCH 7/8] net: davinci_mdio: remove unnecessary dev_set_drvdata()
Date: Wed, 21 Aug 2013 15:02:41 +0800
Message-ID: <1377068561-15744-1-git-send-email-libo.chen@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <mugunthanvnm@ti.com>, <bigeasy@linutronix.de>,
	<prabhakar.csengg@gmail.com>, <netdev@vger.kernel.org>,
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
 drivers/net/ethernet/ti/davinci_mdio.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
index 01b0cc5..7f85143 100644
--- a/drivers/net/ethernet/ti/davinci_mdio.c
+++ b/drivers/net/ethernet/ti/davinci_mdio.c
@@ -433,8 +433,6 @@ static int davinci_mdio_remove(struct platform_device *pdev)
 	pm_runtime_put_sync(&pdev->dev);
 	pm_runtime_disable(&pdev->dev);
 
-	dev_set_drvdata(dev, NULL);
-
 	kfree(data);
 
 	return 0;
-- 
1.7.1
