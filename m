From: Libo Chen <libo.chen@huawei.com>
Subject: [PATCH 4/8] net: sunbmac: remove unnecessary dev_set_drvdata()
Date: Wed, 21 Aug 2013 15:02:27 +0800
Message-ID: <1377068547-54816-1-git-send-email-libo.chen@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <emilio@elopez.com.ar>, <gregkh@linuxfoundation.org>,
	<wfp5p@virginia.edu>, <netdev@vger.kernel.org>,
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
 drivers/net/ethernet/sun/sunbmac.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunbmac.c b/drivers/net/ethernet/sun/sunbmac.c
index 0a32ca5..7217ee5 100644
--- a/drivers/net/ethernet/sun/sunbmac.c
+++ b/drivers/net/ethernet/sun/sunbmac.c
@@ -1259,8 +1259,6 @@ static int bigmac_sbus_remove(struct platform_device *op)
 
 	free_netdev(net_dev);
 
-	dev_set_drvdata(&op->dev, NULL);
-
 	return 0;
 }
 
-- 
1.7.1
