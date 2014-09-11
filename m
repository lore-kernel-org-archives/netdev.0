From: Subbaraya Sundeep Bhatta <subbaraya.sundeep.bhatta@xilinx.com>
Subject: [PATCH] net: axienet: remove unnecessary ether_setup after alloc_etherdev
Date: Thu, 11 Sep 2014 14:53:33 +0530
Message-ID: <78ce1faf-0bf8-41bb-a30d-cecd11d82d94@BY2FFO11FD033.protection.gbl>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <michals@xilinx.com>, <svemula@xilinx.com>, <anirudh@xilinx.com>,
	Subbaraya Sundeep Bhatta <sbhatta@xilinx.com>
To: <davem@davemloft.net>, <jeffrey.t.kirsher@intel.com>,
	<jesse.brandeburg@intel.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0079.outbound.protection.outlook.com ([207.46.100.79]:36425
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753923AbaIKJ5f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Sep 2014 05:57:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

calling ether_setup is redundant since alloc_etherdev calls
it.

Signed-off-by: Subbaraya Sundeep Bhatta <sbhatta@xilinx.com>
---
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
index c8fd941..4ea2d4e 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
@@ -1485,7 +1485,6 @@ static int axienet_of_probe(struct platform_device *op)
 	if (!ndev)
 		return -ENOMEM;
 
-	ether_setup(ndev);
 	platform_set_drvdata(op, ndev);
 
 	SET_NETDEV_DEV(ndev, &op->dev);
-- 
1.7.4
