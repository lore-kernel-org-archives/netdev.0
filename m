From: Christos Gkekas <chris.gekas@gmail.com>
Subject: [PATCH] ath9k: debug: Remove redundant check
Date: Sat, 14 Oct 2017 10:46:11 +0100
Message-ID: <1507974371-7419-1-git-send-email-chris.gekas@gmail.com>
Cc: Christos Gkekas <chris.gekas@gmail.com>
To: QCA ath9k Development <ath9k-devel@qca.qualcomm.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Variable val is unsigned, so checking whether it is less than zero is
redundant.

Signed-off-by: Christos Gkekas <chris.gekas@gmail.com>
---
 drivers/net/wireless/ath/ath9k/debug.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/ath9k/debug.c b/drivers/net/wireless/ath/ath9k/debug.c
index 01fa301..4f5f141 100644
--- a/drivers/net/wireless/ath/ath9k/debug.c
+++ b/drivers/net/wireless/ath/ath9k/debug.c
@@ -1167,7 +1167,7 @@ static ssize_t write_file_tpc(struct file *file, const char __user *user_buf,
 	if (kstrtoul(buf, 0, &val))
 		return -EINVAL;
 
-	if (val < 0 || val > 1)
+	if (val > 1)
 		return -EINVAL;
 
 	tpc_enabled = !!val;
-- 
2.7.4
