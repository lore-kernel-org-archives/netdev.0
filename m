From: Christos Gkekas <chris.gekas@gmail.com>
Subject: [PATCH] ath10k: spectral: Remove redundant check
Date: Sat, 14 Oct 2017 10:41:15 +0100
Message-ID: <1507974075-6987-1-git-send-email-chris.gekas@gmail.com>
Cc: Christos Gkekas <chris.gekas@gmail.com>
To: Kalle Valo <kvalo@qca.qualcomm.com>, ath10k@lists.infradead.org,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Variable val is unsigned, so checking whether it is less than zero is
redundant.

Signed-off-by: Christos Gkekas <chris.gekas@gmail.com>
---
 drivers/net/wireless/ath/ath10k/spectral.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/ath10k/spectral.c b/drivers/net/wireless/ath/ath10k/spectral.c
index dd9cc09..2048b1e 100644
--- a/drivers/net/wireless/ath/ath10k/spectral.c
+++ b/drivers/net/wireless/ath/ath10k/spectral.c
@@ -406,7 +406,7 @@ static ssize_t write_file_spectral_count(struct file *file,
 	if (kstrtoul(buf, 0, &val))
 		return -EINVAL;
 
-	if (val < 0 || val > 255)
+	if (val > 255)
 		return -EINVAL;
 
 	mutex_lock(&ar->conf_mutex);
-- 
2.7.4
