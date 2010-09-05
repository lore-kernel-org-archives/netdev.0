From: Joe Perches <joe@perches.com>
Subject: [PATCH 03/13] drivers/net/wireless/iwlwifi: Remove unnecessary casts of private_data
Date: Sat,  4 Sep 2010 18:52:44 -0700
Message-ID: <0edcdb63c6c57d0cf810e8c637cf7e8163b80962.1283650107.git.joe@perches.com>
References: <cover.1283650107.git.joe@perches.com>
Cc: Reinette Chatre <reinette.chatre@intel.com>,
	Wey-Yi Guy <wey-yi.w.guy@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jiri Kosina <trivial@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1346 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754644Ab0IEBxH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Sep 2010 21:53:07 -0400
In-Reply-To: <cover.1283650107.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/iwlwifi/iwl-agn-debugfs.c |    2 +-
 drivers/net/wireless/iwlwifi/iwl-debugfs.c     |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-debugfs.c b/drivers/net/wireless/iwlwifi/iwl-agn-debugfs.c
index d706b8a..215d29e 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-debugfs.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-debugfs.c
@@ -929,7 +929,7 @@ ssize_t iwl_ucode_bt_stats_read(struct file *file,
 				char __user *user_buf,
 				size_t count, loff_t *ppos)
 {
-	struct iwl_priv *priv = (struct iwl_priv *)file->private_data;
+	struct iwl_priv *priv = file->private_data;
 	int pos = 0;
 	char *buf;
 	int bufsz = (sizeof(struct statistics_bt_activity) * 24) + 200;
diff --git a/drivers/net/wireless/iwlwifi/iwl-debugfs.c b/drivers/net/wireless/iwlwifi/iwl-debugfs.c
index 0ee8f51..85e5ad4 100644
--- a/drivers/net/wireless/iwlwifi/iwl-debugfs.c
+++ b/drivers/net/wireless/iwlwifi/iwl-debugfs.c
@@ -1528,7 +1528,7 @@ static ssize_t iwl_dbgfs_ucode_bt_stats_read(struct file *file,
 					char __user *user_buf,
 					size_t count, loff_t *ppos)
 {
-	struct iwl_priv *priv = (struct iwl_priv *)file->private_data;
+	struct iwl_priv *priv = file->private_data;
 
 	return priv->cfg->ops->lib->debugfs_ops.bt_stats_read(file,
 			user_buf, count, ppos);
@@ -1566,7 +1566,7 @@ static ssize_t iwl_dbgfs_bt_traffic_read(struct file *file,
 					char __user *user_buf,
 					size_t count, loff_t *ppos) {
 
-	struct iwl_priv *priv = (struct iwl_priv *)file->private_data;
+	struct iwl_priv *priv = file->private_data;
 	int pos = 0;
 	char buf[200];
 	const size_t bufsz = sizeof(buf);
-- 
1.7.2.19.g9a302

