From: Libo Chen <libo.chen@huawei.com>
Subject: [PATCH 13/19] drivers/net/ethernet/calxeda: add missing platform_driver owner
Date: Tue, 21 May 2013 10:42:37 +0800
Message-ID: <1369104157-13912-1-git-send-email-libo.chen@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<lizefan@huawei.com>, <davem@davemloft.net>, <libo.chen@huawei.com>
To: <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

set the owner of platform_driver, to ensure that the
caller of driver holds a module refernece

Signed-off-by: Libo Chen <libo.chen@huawei.com>
---
 drivers/net/ethernet/calxeda/xgmac.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/calxeda/xgmac.c b/drivers/net/ethernet/calxeda/xgmac.c
index 4a1f2fa..493f618 100644
--- a/drivers/net/ethernet/calxeda/xgmac.c
+++ b/drivers/net/ethernet/calxeda/xgmac.c
@@ -1899,6 +1899,7 @@ MODULE_DEVICE_TABLE(of, xgmac_of_match);
 static struct platform_driver xgmac_driver = {
 	.driver = {
 		.name = "calxedaxgmac",
+		.owner = THIS_MODULE,
 		.of_match_table = xgmac_of_match,
 	},
 	.probe = xgmac_probe,
-- 
1.7.1
