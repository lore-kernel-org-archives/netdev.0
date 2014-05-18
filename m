From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 2/3] batman-adv: remove semi-colon after macro definition
Date: Sun, 18 May 2014 19:58:09 +0200
Message-ID: <1400435890-6667-3-git-send-email-antonio@meshcoding.com>
References: <1400435890-6667-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@meshcoding.com>,
	Marek Lindner <mareklindner@neomailbox.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:16458 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751126AbaERR7e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 May 2014 13:59:34 -0400
In-Reply-To: <1400435890-6667-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reported by checkpatch with the following warning:
"WARNING: macros should not use a trailing semicolon"

Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
---
 net/batman-adv/debugfs.c | 4 ++--
 net/batman-adv/sysfs.c   | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/batman-adv/debugfs.c b/net/batman-adv/debugfs.c
index 99f2ba0..a12e25e 100644
--- a/net/batman-adv/debugfs.c
+++ b/net/batman-adv/debugfs.c
@@ -342,7 +342,7 @@ struct batadv_debuginfo batadv_debuginfo_##_name = {	\
 		  .llseek = seq_lseek,			\
 		  .release = single_release,		\
 		}					\
-};
+}
 
 /* the following attributes are general and therefore they will be directly
  * placed in the BATADV_DEBUGFS_SUBDIR subdirectory of debugfs
@@ -404,7 +404,7 @@ struct batadv_debuginfo batadv_hardif_debuginfo_##_name = {	\
 		.llseek = seq_lseek,				\
 		.release = single_release,			\
 	},							\
-};
+}
 static BATADV_HARDIF_DEBUGINFO(originators, S_IRUGO,
 			       batadv_originators_hardif_open);
 
diff --git a/net/batman-adv/sysfs.c b/net/batman-adv/sysfs.c
index f51b484..fc47baa 100644
--- a/net/batman-adv/sysfs.c
+++ b/net/batman-adv/sysfs.c
@@ -108,7 +108,7 @@ struct batadv_attribute batadv_attr_vlan_##_name = {	\
 		 .mode = _mode },			\
 	.show   = _show,				\
 	.store  = _store,				\
-};
+}
 
 /* Use this, if you have customized show and store functions */
 #define BATADV_ATTR(_name, _mode, _show, _store)	\
@@ -117,7 +117,7 @@ struct batadv_attribute batadv_attr_##_name = {		\
 		 .mode = _mode },			\
 	.show   = _show,				\
 	.store  = _store,				\
-};
+}
 
 #define BATADV_ATTR_SIF_STORE_BOOL(_name, _post_func)			\
 ssize_t batadv_store_##_name(struct kobject *kobj,			\
-- 
1.8.5.5
