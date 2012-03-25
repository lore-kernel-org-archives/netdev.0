From: dbaluta@ixiacom.com
Subject: [PATCH] can: fix sparse warning for cgw_list
Date: Mon, 26 Mar 2012 02:05:50 +0300
Message-ID: <1332716750-3455-1-git-send-email-dbaluta@ixiacom.com>
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	Daniel Baluta <daniel.baluta@gmail.com>,
	Daniel Baluta <dbaluta@ixiacom.com>
To: socketcan@hartkopp.net, davem@davemloft.net
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daniel Baluta <daniel.baluta@gmail.com>

Make cgw_list static to remove the following sparse warning:
net/can/gw.c:69:1: warning: symbol 'cgw_list' was not declared.
Should it be static?

Signed-off-by: Daniel Baluta <dbaluta@ixiacom.com>
---
 net/can/gw.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/can/gw.c b/net/can/gw.c
index 3d79b12..b41acf2 100644
--- a/net/can/gw.c
+++ b/net/can/gw.c
@@ -66,7 +66,7 @@ MODULE_LICENSE("Dual BSD/GPL");
 MODULE_AUTHOR("Oliver Hartkopp <oliver.hartkopp@volkswagen.de>");
 MODULE_ALIAS("can-gw");
 
-HLIST_HEAD(cgw_list);
+static HLIST_HEAD(cgw_list);
 static struct notifier_block notifier;
 
 static struct kmem_cache *cgw_cache __read_mostly;
-- 
1.7.1

