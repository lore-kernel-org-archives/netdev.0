From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH] drivers/net: replace IS_ERR and PTR_ERR with PTR_ERR_OR_ZERO
Date: Fri, 1 Nov 2013 18:00:16 +0800
Message-ID: <1383300016-5947-1-git-send-email-duanj.fnst@cn.fujitsu.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Duan Jiong <duanj.fnst@cn.fujitsu.com>
To: acme@ghostprotocols.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes coccinelle error regarding usage of IS_ERR and
PTR_ERR instead of PTR_ERR_OR_ZERO.

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---
 drivers/net/appletalk/ipddp.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/appletalk/ipddp.c b/drivers/net/appletalk/ipddp.c
index 10d0dba..78f06cb 100644
--- a/drivers/net/appletalk/ipddp.c
+++ b/drivers/net/appletalk/ipddp.c
@@ -312,9 +312,7 @@ module_param(ipddp_mode, int, 0);
 static int __init ipddp_init_module(void)
 {
 	dev_ipddp = ipddp_init();
-        if (IS_ERR(dev_ipddp))
-                return PTR_ERR(dev_ipddp);
-	return 0;
+        return PTR_ERR_OR_ZERO(dev_ipddp);
 }
 
 static void __exit ipddp_cleanup_module(void)
-- 
1.8.3.1
