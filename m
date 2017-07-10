From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH] wireless: iwlegacy: constify attribute_group structures.
Date: Mon, 10 Jul 2017 15:12:53 +0530
Message-ID: <4333d7c1a2e0c5def85b1d0a42672499890f9f4c.1499679699.git.arvind.yadav.cs@gmail.com>
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
 drivers/net/wireless/intel/iwlegacy/3945-mac.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/intel/iwlegacy/3945-mac.c b/drivers/net/wireless/intel/iwlegacy/3945-mac.c
index 38bf403..329f3a6 100644
--- a/drivers/net/wireless/intel/iwlegacy/3945-mac.c
+++ b/drivers/net/wireless/intel/iwlegacy/3945-mac.c
@@ -3464,7 +3464,7 @@ static DEVICE_ATTR(antenna, S_IWUSR | S_IRUGO, il3945_show_antenna,
 	NULL
 };
 
-static struct attribute_group il3945_attribute_group = {
+static const struct attribute_group il3945_attribute_group = {
 	.name = NULL,		/* put in device directory */
 	.attrs = il3945_sysfs_entries,
 };
-- 
1.9.1
