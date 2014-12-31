From: Nicholas Mc Guire <der.herr@hofr.at>
Subject: [PATCH] wait_for_completion_timeout does not return < 0
Date: Wed, 31 Dec 2014 04:04:03 -0500
Message-ID: <1420016643-19707-1-git-send-email-der.herr@hofr.at>
Cc: linux-wimax@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Nicholas Mc Guire <der.herr@hofr.at>
To: Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is only removing the comment which is misleading as
wait_for_completion_timeout does not return < 0 thus there
never is anything to be passed on.

patch is against linux-next 3.19.0-rc1 -next-20141226

Signed-off-by: Nicholas Mc Guire <der.herr@hofr.at>
---
 drivers/net/wimax/i2400m/driver.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/wimax/i2400m/driver.c b/drivers/net/wimax/i2400m/driver.c
index 9c78090..0a6384e 100644
--- a/drivers/net/wimax/i2400m/driver.c
+++ b/drivers/net/wimax/i2400m/driver.c
@@ -197,7 +197,6 @@ int i2400m_op_reset(struct wimax_dev *wimax_dev)
 		result = -ETIMEDOUT;
 	else if (result > 0)
 		result = ctx.result;
-	/* if result < 0, pass it on */
 	mutex_lock(&i2400m->init_mutex);
 	i2400m->reset_ctx = NULL;
 	mutex_unlock(&i2400m->init_mutex);
-- 
1.7.10.4
