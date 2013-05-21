From: Libo Chen <libo.chen@huawei.com>
Subject: [PATCH 08/19] drivers/net/ethernet/amd: add missing platform_driver owner
Date: Tue, 21 May 2013 10:42:24 +0800
Message-ID: <1369104144-712-1-git-send-email-libo.chen@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<davem@davemloft.net>, <lizefan@huawei.com>, <libo.chen@huawei.com>
To: <linux@arm.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

set the owner of platform_driver, to ensure that the
caller of driver holds a module refernece

Signed-off-by: Libo Chen <libo.chen@huawei.com>
---
 drivers/net/ethernet/amd/am79c961a.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/amd/am79c961a.c b/drivers/net/ethernet/amd/am79c961a.c
index 9793767..a1a890b 100644
--- a/drivers/net/ethernet/amd/am79c961a.c
+++ b/drivers/net/ethernet/amd/am79c961a.c
@@ -757,6 +757,7 @@ static struct platform_driver am79c961_driver = {
 	.probe		= am79c961_probe,
 	.driver		= {
 		.name	= "am79c961",
+		.owner	= THIS_MODULE,
 	},
 };
 
-- 
1.7.1
