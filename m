From: Libo Chen <libo.chen@huawei.com>
Subject: [PATCH 19/19] drivers/net/ethernet/renesas: add missing platform_driver owner
Date: Tue, 21 May 2013 10:42:53 +0800
Message-ID: <1369104173-11704-1-git-send-email-libo.chen@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <lizefan@huawei.com>,
	<libo.chen@huawei.com>
To: <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

set the owner of platform_driver, to ensure that the
caller of driver holds a module refernece

Signed-off-by: Libo Chen <libo.chen@huawei.com>
---
 drivers/net/ethernet/renesas/sh_eth.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 42e9dd0..0519480 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -2831,6 +2831,7 @@ static struct platform_driver sh_eth_driver = {
 	.remove = sh_eth_drv_remove,
 	.driver = {
 		   .name = CARDNAME,
+		   .owner = THIS_MODULE,
 		   .pm = &sh_eth_dev_pm_ops,
 	},
 };
-- 
1.7.1
