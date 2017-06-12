From: Joe Perches <joe@perches.com>
Subject: [PATCH] netconsole: Remove duplicate "netconsole: " logging prefix
Date: Mon, 12 Jun 2017 16:39:51 -0700
Message-ID: <a61deabca48ccbbfb1b0d077881d114ad0c5bc75.1497310740.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It's already added by pr_fmt so remove the explicit use.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/netconsole.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index 06ee6395117f..0e27920c2b6b 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -358,7 +358,7 @@ static ssize_t enabled_store(struct config_item *item,
 		if (err)
 			goto out_unlock;
 
-		pr_info("netconsole: network logging started\n");
+		pr_info("network logging started\n");
 	} else {	/* false */
 		/* We need to disable the netconsole before cleaning it up
 		 * otherwise we might end up in write_msg() with
-- 
2.10.0.rc2.1.g053435c
