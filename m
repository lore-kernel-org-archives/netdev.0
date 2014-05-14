From: Joe Perches <joe@perches.com>
Subject: [PATCH 2/2] wlcore: Remove trailing semicolon from do {...} while (0) macro
Date: Wed, 14 May 2014 12:15:14 -0700
Message-ID: <a62dbcaa8438b3ee6cdf94d7681427c6f48f122a.1400094804.git.joe@perches.com>
References: <cover.1400094804.git.joe@perches.com>
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1400094804.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These should not have trailing semicolons so remove them.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/ti/wlcore/debugfs.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/ti/wlcore/debugfs.h b/drivers/net/wireless/ti/wlcore/debugfs.h
index f7381dd..0f2cfb0 100644
--- a/drivers/net/wireless/ti/wlcore/debugfs.h
+++ b/drivers/net/wireless/ti/wlcore/debugfs.h
@@ -57,7 +57,7 @@ static const struct file_operations name## _ops = {			\
 					    wl, &name## _ops);		\
 		if (!entry || IS_ERR(entry))				\
 			goto err;					\
-	} while (0);
+	} while (0)
 
 
 #define DEBUGFS_ADD_PREFIX(prefix, name, parent)			\
@@ -66,7 +66,7 @@ static const struct file_operations name## _ops = {			\
 				    wl, &prefix## _## name## _ops);	\
 		if (!entry || IS_ERR(entry))				\
 			goto err;					\
-	} while (0);
+	} while (0)
 
 #define DEBUGFS_FWSTATS_FILE(sub, name, fmt, struct_type)		\
 static ssize_t sub## _ ##name## _read(struct file *file,		\
-- 
1.8.1.2.459.gbcd45b4.dirty
