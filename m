From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH] wireless: ipw2100: constify attribute_group structures.
Date: Mon, 10 Jul 2017 15:09:25 +0530
Message-ID: <04712fc07659c2480e9e37e8f5d3fd1e2841840b.1499679464.git.arvind.yadav.cs@gmail.com>
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: stas.yakovlev@gmail.com, kvalo@codeaurora.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34918 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752469AbdGJJjv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Jul 2017 05:39:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

attribute_groups are not supposed to change at runtime. All functions
working with attribute_groups provided by <linux/sysfs.h> work
with const attribute_group. So mark the non-const structs as const.

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
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
