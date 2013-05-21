From: Libo Chen <libo.chen@huawei.com>
Subject: [PATCH 16/19] drivers/net/wan: add missing platform_driver owner
Date: Tue, 21 May 2013 10:42:45 +0800
Message-ID: <1369104165-27484-1-git-send-email-libo.chen@huawei.com>
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
 drivers/net/wan/ixp4xx_hss.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wan/ixp4xx_hss.c b/drivers/net/wan/ixp4xx_hss.c
index fc9d11d..db2d775 100644
--- a/drivers/net/wan/ixp4xx_hss.c
+++ b/drivers/net/wan/ixp4xx_hss.c
@@ -1391,6 +1391,7 @@ static int hss_remove_one(struct platform_device *pdev)
 
 static struct platform_driver ixp4xx_hss_driver = {
 	.driver.name	= DRV_NAME,
+	.driver.owner	= THIS_MODULE,
 	.probe		= hss_init_one,
 	.remove		= hss_remove_one,
 };
-- 
1.7.1
