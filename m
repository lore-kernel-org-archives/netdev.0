From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH] wireless: iwlegacy: Constify attribute_group structures.
Date: Mon, 10 Jul 2017 15:21:42 +0530
Message-ID: <ec85da590a1239a98e24b696eb11e3cf1739fd4d.1499680248.git.arvind.yadav.cs@gmail.com>
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: sgruszka@redhat.com, kvalo@codeaurora.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

attribute_groups are not supposed to change at runtime. All functions
working with attribute_groups provided by <linux/sysfs.h> work
with const attribute_group. So mark the non-const structs as const.

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/net/wireless/intel/iwlegacy/4965-mac.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/intel/iwlegacy/4965-mac.c b/drivers/net/wireless/intel/iwlegacy/4965-mac.c
index 5b51fba..de9b652 100644
--- a/drivers/net/wireless/intel/iwlegacy/4965-mac.c
+++ b/drivers/net/wireless/intel/iwlegacy/4965-mac.c
@@ -4654,7 +4654,7 @@ static DEVICE_ATTR(tx_power, S_IWUSR | S_IRUGO, il4965_show_tx_power,
 	NULL
 };
 
-static struct attribute_group il_attribute_group = {
+static const struct attribute_group il_attribute_group = {
 	.name = NULL,		/* put in device directory */
 	.attrs = il_sysfs_entries,
 };
-- 
1.9.1
