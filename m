From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH v3 05/10] wireless: ipw2100: constify attribute_group structures.
Date: Tue, 18 Jul 2017 15:15:00 +0530
Message-ID: <1500371102-14758-2-git-send-email-arvind.yadav.cs@gmail.com>
References: <1500371102-14758-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-wireless@vger.kernel.org
To: davem@davemloft.net, stas.yakovlev@gmail.com, kvalo@codeaurora.org,
        sgruszka@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1500371102-14758-1-git-send-email-arvind.yadav.cs@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

attribute_group are not supposed to change at runtime. All functions
working with attribute_group provided by <linux/sysfs.h> work
with const attribute_group. So mark the non-const structs as const.

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
Changes in v2:
              Added cover later.
Changes in v3:
              net-next was closed. Now resubmitting it.

 drivers/net/wireless/intel/ipw2x00/ipw2100.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/intel/ipw2x00/ipw2100.c b/drivers/net/wireless/intel/ipw2x00/ipw2100.c
index aaaca4d..ccbe745 100644
--- a/drivers/net/wireless/intel/ipw2x00/ipw2100.c
+++ b/drivers/net/wireless/intel/ipw2x00/ipw2100.c
@@ -4324,7 +4324,7 @@ static ssize_t store_rf_kill(struct device *d, struct device_attribute *attr,
 	NULL,
 };
 
-static struct attribute_group ipw2100_attribute_group = {
+static const struct attribute_group ipw2100_attribute_group = {
 	.attrs = ipw2100_sysfs_entries,
 };
 
-- 
1.9.1
