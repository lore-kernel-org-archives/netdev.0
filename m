From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH] smsc: replace IS_ERR and PTR_ERR with PTR_ERR_OR_ZERO
Date: Wed, 6 Nov 2013 15:57:17 +0800
Message-ID: <1383724637-15849-1-git-send-email-duanj.fnst@cn.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, rtc-linux@googlegroups.com,
	dri-devel@lists.freedesktop.org, linux-tegra@vger.kernel.org,
	linux-input@vger.kernel.org, devel@driverdev.osuosl.org,
	netdev@vger.kernel.org, Duan Jiong <duanj.fnst@cn.fujitsu.com>
To: kernel@pengutronix.de, linux@arm.linux.org.uk,
	a.zummo@towertech.it, airlied@linux.ie, dmitry.torokhov@gmail.com,
	axboe@kernel.dk
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes coccinelle error regarding usage of IS_ERR and
PTR_ERR instead of PTR_ERR_OR_ZERO.

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---
 drivers/net/ethernet/smsc/smc9194.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smc9194.c b/drivers/net/ethernet/smsc/smc9194.c
index 6f3491f..67d9fde 100644
--- a/drivers/net/ethernet/smsc/smc9194.c
+++ b/drivers/net/ethernet/smsc/smc9194.c
@@ -1545,9 +1545,7 @@ int __init init_module(void)
 
 	/* copy the parameters from insmod into the device structure */
 	devSMC9194 = smc_init(-1);
-	if (IS_ERR(devSMC9194))
-		return PTR_ERR(devSMC9194);
-	return 0;
+	return PTR_ERR_OR_ZERO(devSMC9194);
 }
 
 void __exit cleanup_module(void)
-- 
1.8.3.1
