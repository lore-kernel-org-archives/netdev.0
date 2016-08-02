From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0773/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:45:01 +0800
Message-ID: <20160802114501.1214-1-baolex.ni@intel.com>
Cc: linux-wireless@vger.kernel.org, b43-dev@lists.infradead.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chuansheng.liu@intel.com, baolex.ni@intel.com, lars@metafoo.de,
	johannes.berg@intel.com
To: Larry.Finger@lwfinger.net, kvalo@codeaurora.org,
	bkenward@solarflare.com, linux-driver@qlogic.com,
	computersforpeace@gmail.com, m.chehab@samsung.com,
	pawel@osciak.com, m.szyprowski@samsung.com,
	kyungmin.park@samsung.com, k.kozlowski@samsung.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I find that the developers often just specified the numeric value
when calling a macro which is defined with a parameter for access permission.
As we know, these numeric value for access permission have had the corresponding macro,
and that using macro can improve the robustness and readability of the code,
thus, I suggest replacing the numeric parameter with the macro.

Signed-off-by: Chuansheng Liu <chuansheng.liu@intel.com>
Signed-off-by: Baole Ni <baolex.ni@intel.com>
---
 drivers/net/wireless/broadcom/b43legacy/sysfs.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/broadcom/b43legacy/sysfs.c b/drivers/net/wireless/broadcom/b43legacy/sysfs.c
index 2a1da15..e6543ff 100644
--- a/drivers/net/wireless/broadcom/b43legacy/sysfs.c
+++ b/drivers/net/wireless/broadcom/b43legacy/sysfs.c
@@ -150,7 +150,7 @@ static ssize_t b43legacy_attr_interfmode_store(struct device *dev,
 	return err ? err : count;
 }
 
-static DEVICE_ATTR(interference, 0644,
+static DEVICE_ATTR(interference, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH,
 		   b43legacy_attr_interfmode_show,
 		   b43legacy_attr_interfmode_store);
 
@@ -203,7 +203,7 @@ static ssize_t b43legacy_attr_preamble_store(struct device *dev,
 	return count;
 }
 
-static DEVICE_ATTR(shortpreamble, 0644,
+static DEVICE_ATTR(shortpreamble, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH,
 		   b43legacy_attr_preamble_show,
 		   b43legacy_attr_preamble_store);
 
-- 
2.9.2
