From: Libo Chen <libo.chen@huawei.com>
Subject: [PATCH 15/19] drivers/net/irda: add missing platform_driver owner
Date: Tue, 21 May 2013 10:42:43 +0800
Message-ID: <1369104163-38628-1-git-send-email-libo.chen@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<davem@davemloft.net>, <lizefan@huawei.com>, <libo.chen@huawei.com>
To: <samuel@sortiz.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

set the owner of platform_driver, to ensure that the
caller of driver holds a module refernece

Signed-off-by: Libo Chen <libo.chen@huawei.com>
---
 drivers/net/irda/bfin_sir.c   |    1 +
 drivers/net/irda/sh_irda.c    |    1 +
 drivers/net/irda/sh_sir.c     |    1 +
 drivers/net/irda/smsc-ircc2.c |    1 +
 4 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/irda/bfin_sir.c b/drivers/net/irda/bfin_sir.c
index 22b4527..bf976f3 100644
--- a/drivers/net/irda/bfin_sir.c
+++ b/drivers/net/irda/bfin_sir.c
@@ -806,6 +806,7 @@ static struct platform_driver bfin_ir_driver = {
 	.resume  = bfin_sir_resume,
 	.driver  = {
 		.name = DRIVER_NAME,
+		.owner	= THIS_MODULE,
 	},
 };
 
diff --git a/drivers/net/irda/sh_irda.c b/drivers/net/irda/sh_irda.c
index 9448587..f14ea43 100644
--- a/drivers/net/irda/sh_irda.c
+++ b/drivers/net/irda/sh_irda.c
@@ -865,6 +865,7 @@ static struct platform_driver sh_irda_driver = {
 	.remove	= sh_irda_remove,
 	.driver	= {
 		.name	= DRIVER_NAME,
+		.owner	= THIS_MODULE,
 		.pm	= &sh_irda_pm_ops,
 	},
 };
diff --git a/drivers/net/irda/sh_sir.c b/drivers/net/irda/sh_sir.c
index 24aefcd..3bd058d 100644
--- a/drivers/net/irda/sh_sir.c
+++ b/drivers/net/irda/sh_sir.c
@@ -806,6 +806,7 @@ static struct platform_driver sh_sir_driver = {
 	.remove  = sh_sir_remove,
 	.driver  = {
 		.name = DRIVER_NAME,
+		.owner = THIS_MODULE,
 	},
 };
 
diff --git a/drivers/net/irda/smsc-ircc2.c b/drivers/net/irda/smsc-ircc2.c
index aa05dad..5b3e4d2 100644
--- a/drivers/net/irda/smsc-ircc2.c
+++ b/drivers/net/irda/smsc-ircc2.c
@@ -260,6 +260,7 @@ static struct platform_driver smsc_ircc_driver = {
 	.resume		= smsc_ircc_resume,
 	.driver		= {
 		.name	= SMSC_IRCC2_DRIVER_NAME,
+		.owner	= THIS_MODULE,
 	},
 };
 
-- 
1.7.1
