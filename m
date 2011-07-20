From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH 2/3] wireless: ath9k: use %pM to print MAC
Date: Wed, 20 Jul 2011 16:34:30 +0300
Message-ID: <e9d4e9e2edf4c51412c141140d51e9baf9ff13a3.1311162926.git.andriy.shevchenko@linux.intel.com>
References: <fddeabc04a1b81a5c1f51a4164d93366dccf5f8e.1311162926.git.andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	"Luis R. Rodriguez" <lrodriguez@atheros.com>,
	ath9k-devel@lists.ath9k.org
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <fddeabc04a1b81a5c1f51a4164d93366dccf5f8e.1311162926.git.andriy.shevchenko@linux.intel.com>
In-Reply-To: <fddeabc04a1b81a5c1f51a4164d93366dccf5f8e.1311162926.git.andriy.shevchenko@linux.intel.com>
References: <fddeabc04a1b81a5c1f51a4164d93366dccf5f8e.1311162926.git.andriy.shevchenko@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Cc: "Luis R. Rodriguez" <lrodriguez@atheros.com>
Cc: ath9k-devel@lists.ath9k.org
---
 drivers/net/wireless/ath/ath9k/htc_drv_debug.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_debug.c b/drivers/net/wireless/ath/ath9k/htc_drv_debug.c
index aa48b3a..d3ff33c 100644
--- a/drivers/net/wireless/ath/ath9k/htc_drv_debug.c
+++ b/drivers/net/wireless/ath/ath9k/htc_drv_debug.c
@@ -623,11 +623,8 @@ static ssize_t read_file_base_eeprom(struct file *file, char __user *user_buf,
 				pBase9287->openLoopPwrCntl);
 	}
 
-	len += snprintf(buf + len, size - len,
-			"%20s : %02X:%02X:%02X:%02X:%02X:%02X\n",
-			"MacAddress",
-			pBase->macAddr[0], pBase->macAddr[1], pBase->macAddr[2],
-			pBase->macAddr[3], pBase->macAddr[4], pBase->macAddr[5]);
+	len += snprintf(buf + len, size - len, "%20s : %pM\n", "MacAddress",
+			pBase->macAddr);
 	if (len > size)
 		len = size;
 
-- 
1.7.5.4
