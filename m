From: Libo Chen <libo.chen@huawei.com>
Subject: [PATCH 11/19] drivers/net/ethernet/natsemi: add missing platform_driver owner
Date: Tue, 21 May 2013 10:42:32 +0800
Message-ID: <1369104152-20152-1-git-send-email-libo.chen@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<davem@davemloft.net>, <lizefan@huawei.com>, <libo.chen@huawei.com>
To: <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

set the owner of platform_driver, to ensure that the
caller of driver holds a module refernece

Signed-off-by: Libo Chen <libo.chen@huawei.com>
---
 drivers/net/ethernet/natsemi/xtsonic.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/natsemi/xtsonic.c b/drivers/net/ethernet/natsemi/xtsonic.c
index c2e0256..9281781 100644
--- a/drivers/net/ethernet/natsemi/xtsonic.c
+++ b/drivers/net/ethernet/natsemi/xtsonic.c
@@ -315,6 +315,7 @@ static struct platform_driver xtsonic_driver = {
 	.remove = xtsonic_device_remove,
 	.driver = {
 		.name = xtsonic_string,
+		.owner	= THIS_MODULE,
 	},
 };
 
-- 
1.7.1
