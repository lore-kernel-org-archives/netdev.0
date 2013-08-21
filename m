From: Libo Chen <libo.chen@huawei.com>
Subject: [PATCH 6/8] net: xilinx_emaclite: remove unnecessary dev_set_drvdata()
Date: Wed, 21 Aug 2013 15:02:36 +0800
Message-ID: <1377068556-51316-1-git-send-email-libo.chen@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <michal.simek@xilinx.com>, <renner@efe-gmbh.de>,
	<gregkh@linuxfoundation.org>, <netdev@vger.kernel.org>,
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
 drivers/net/ethernet/xilinx/xilinx_emaclite.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/xilinx_emaclite.c b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
index 7c1ccbc..4c619ea 100644
--- a/drivers/net/ethernet/xilinx/xilinx_emaclite.c
+++ b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
@@ -1249,7 +1249,6 @@ static int xemaclite_of_remove(struct platform_device *of_dev)
 	lp->phy_node = NULL;
 
 	xemaclite_remove_ndev(ndev, of_dev);
-	dev_set_drvdata(dev, NULL);
 
 	return 0;
 }
-- 
1.7.1
