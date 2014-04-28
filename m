From: Masanari Iida <standby24x7@gmail.com>
Subject: [PATCH] net: bonding: Fix format string mismatch in bond_sysfs.c
Date: Tue, 29 Apr 2014 00:41:21 +0900
Message-ID: <1398699681-27339-1-git-send-email-standby24x7@gmail.com>
Cc: Masanari Iida <standby24x7@gmail.com>
To: netdev@vger.kernel.org, j.vosburgh@gmail.com, vfalico@gmail.com,
	andy@greyhouse.net, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix format string mismatch in bonding_show_min_links().

Signed-off-by: Masanari Iida <standby24x7@gmail.com>
---
 drivers/net/bonding/bond_sysfs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 431892f..cb95ee4 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -534,7 +534,7 @@ static ssize_t bonding_show_min_links(struct device *d,
 {
 	struct bonding *bond = to_bond(d);
 
-	return sprintf(buf, "%d\n", bond->params.min_links);
+	return sprintf(buf, "%u\n", bond->params.min_links);
 }
 
 static ssize_t bonding_store_min_links(struct device *d,
-- 
2.0.0.rc1
