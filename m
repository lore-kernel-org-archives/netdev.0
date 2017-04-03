From: Colin King <colin.king@canonical.com>
Subject: [PATCH] wlcore: fix spelling mistake in wl1271_warning 'iligal' -> 'illegal'
Date: Mon,  3 Apr 2017 10:15:30 +0100
Message-ID: <20170403091530.18564-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Kalle Valo <kvalo@codeaurora.org>, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

trivial fix to spelling mistake in wl1271_warning error message

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/wireless/ti/wlcore/debugfs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ti/wlcore/debugfs.c b/drivers/net/wireless/ti/wlcore/debugfs.c
index 58e148d7bc7b..416080adc181 100644
--- a/drivers/net/wireless/ti/wlcore/debugfs.c
+++ b/drivers/net/wireless/ti/wlcore/debugfs.c
@@ -1249,7 +1249,7 @@ static ssize_t fw_logger_write(struct file *file,
 	}
 
 	if (wl->conf.fwlog.output == 0) {
-		wl1271_warning("iligal opperation - fw logger disabled by default, please change mode via wlconf");
+		wl1271_warning("illegal opperation - fw logger disabled by default, please change mode via wlconf");
 		return -EINVAL;
 	}
 
-- 
2.11.0
