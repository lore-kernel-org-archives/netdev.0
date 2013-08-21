From: Libo Chen <libo.chen@huawei.com>
Subject: [PATCH 2/8] net: ucc_geth: remove unnecessary dev_set_drvdata()
Date: Wed, 21 Aug 2013 15:02:18 +0800
Message-ID: <1377068538-22432-1-git-send-email-libo.chen@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <leoli@freescale.com>, <netdev@vger.kernel.org>,
	<linuxppc-dev@lists.ozlabs.org>, <linux-kernel@vger.kernel.org>,
	<lizefan@huawei.com>, <libo.chen@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Unnecessary dev_set_drvdata() is removed, because the driver core
clears the driver data to NULL after device_release or on probe failure.

Signed-off-by: Libo Chen <libo.chen@huawei.com>
---
 drivers/net/ethernet/freescale/ucc_geth.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/freescale/ucc_geth.c b/drivers/net/ethernet/freescale/ucc_geth.c
index 533885c..5930c39 100644
--- a/drivers/net/ethernet/freescale/ucc_geth.c
+++ b/drivers/net/ethernet/freescale/ucc_geth.c
@@ -3917,7 +3917,6 @@ static int ucc_geth_remove(struct platform_device* ofdev)
 	unregister_netdev(dev);
 	free_netdev(dev);
 	ucc_geth_memclean(ugeth);
-	dev_set_drvdata(device, NULL);
 
 	return 0;
 }
-- 
1.7.1
