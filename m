From: kaber@trash.net
Subject: [PATCH 35/84] netfilter: xt_recent: allow changing ip_list_[ug]id at runtime
Date: Mon, 10 May 2010 22:18:06 +0200
Message-ID: <1273522735-24672-36-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Engelhardt <jengelh@medozas.de>

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 net/netfilter/xt_recent.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/xt_recent.c b/net/netfilter/xt_recent.c
index 72cbced..8530944 100644
--- a/net/netfilter/xt_recent.c
+++ b/net/netfilter/xt_recent.c
@@ -51,14 +51,14 @@ module_param(ip_list_tot, uint, 0400);
 module_param(ip_pkt_list_tot, uint, 0400);
 module_param(ip_list_hash_size, uint, 0400);
 module_param(ip_list_perms, uint, 0400);
-module_param(ip_list_uid, uint, 0400);
-module_param(ip_list_gid, uint, 0400);
+module_param(ip_list_uid, uint, S_IRUGO | S_IWUSR);
+module_param(ip_list_gid, uint, S_IRUGO | S_IWUSR);
 MODULE_PARM_DESC(ip_list_tot, "number of IPs to remember per list");
 MODULE_PARM_DESC(ip_pkt_list_tot, "number of packets per IP address to remember (max. 255)");
 MODULE_PARM_DESC(ip_list_hash_size, "size of hash table used to look up IPs");
 MODULE_PARM_DESC(ip_list_perms, "permissions on /proc/net/xt_recent/* files");
-MODULE_PARM_DESC(ip_list_uid,"owner of /proc/net/xt_recent/* files");
-MODULE_PARM_DESC(ip_list_gid,"owning group of /proc/net/xt_recent/* files");
+MODULE_PARM_DESC(ip_list_uid, "default owner of /proc/net/xt_recent/* files");
+MODULE_PARM_DESC(ip_list_gid, "default owning group of /proc/net/xt_recent/* files");
 
 struct recent_entry {
 	struct list_head	list;
-- 
1.7.0.4

