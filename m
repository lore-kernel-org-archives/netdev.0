From: Colin King <colin.king@canonical.com>
Subject: [PATCH] wlcore: fix spelling mistake in wl1271_warning
Date: Thu, 29 Dec 2016 20:14:00 +0000
Message-ID: <20161229201400.26830-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: Kalle Valo <kvalo@codeaurora.org>, Shahar Patury <shaharp@ti.com>,
        Guy Mishol <guym@ti.com>, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

trivial fix to spelling mistake of function name in wl1271_warning,
should be dynamic_ps_timeout instead of dyanmic_ps_timeout.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/wireless/ti/wlcore/debugfs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ti/wlcore/debugfs.c b/drivers/net/wireless/ti/wlcore/debugfs.c
index 7f672f6..58e148d 100644
--- a/drivers/net/wireless/ti/wlcore/debugfs.c
+++ b/drivers/net/wireless/ti/wlcore/debugfs.c
@@ -281,7 +281,7 @@ static ssize_t dynamic_ps_timeout_write(struct file *file,
 	}
 
 	if (value < 1 || value > 65535) {
-		wl1271_warning("dyanmic_ps_timeout is not in valid range");
+		wl1271_warning("dynamic_ps_timeout is not in valid range");
 		return -ERANGE;
 	}
 
-- 
2.10.2
