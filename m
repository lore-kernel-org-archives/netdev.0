From: Libo Chen <libo.chen@huawei.com>
Subject: [PATCH 17/19] drivers/net/ethernet/nxp: add missing platform_driver owner
Date: Tue, 21 May 2013 10:42:48 +0800
Message-ID: <1369104168-26332-1-git-send-email-libo.chen@huawei.com>
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
 drivers/net/ethernet/nxp/lpc_eth.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/nxp/lpc_eth.c b/drivers/net/ethernet/nxp/lpc_eth.c
index 55a5548..1f72325 100644
--- a/drivers/net/ethernet/nxp/lpc_eth.c
+++ b/drivers/net/ethernet/nxp/lpc_eth.c
@@ -1600,6 +1600,7 @@ static struct platform_driver lpc_eth_driver = {
 #endif
 	.driver		= {
 		.name	= MODNAME,
+		.owner	= THIS_MODULE,
 		.of_match_table = of_match_ptr(lpc_eth_match),
 	},
 };
-- 
1.7.1
