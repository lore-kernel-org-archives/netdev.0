From: Joe Perches <joe@perches.com>
Subject: [PATCH wireless-next 3/3] ath6kl: Add __printf verification to ath6kl_printk
Date: Sun, 18 Mar 2012 17:30:54 -0700
Message-ID: <a27a7b0fcddc2f2366ff5ab0968ca0ff78d420c5.1332116921.git.joe@perches.com>
References: <cover.1332116921.git.joe@perches.com>
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Kalle Valo <kvalo@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1332116921.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make sure printf formats and arguments match.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/ath/ath6kl/common.h |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/ath/ath6kl/common.h b/drivers/net/wireless/ath/ath6kl/common.h
index a60e78c..71f5450 100644
--- a/drivers/net/wireless/ath/ath6kl/common.h
+++ b/drivers/net/wireless/ath/ath6kl/common.h
@@ -22,7 +22,8 @@
 
 #define ATH6KL_MAX_IE			256
 
-extern int ath6kl_printk(const char *level, const char *fmt, ...);
+extern __printf(2, 3)
+int ath6kl_printk(const char *level, const char *fmt, ...);
 
 /*
  * Reflects the version of binary interface exposed by ATH6KL target
-- 
1.7.8.111.gad25c.dirty
