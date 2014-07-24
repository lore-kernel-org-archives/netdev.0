From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net-next PATCH 1/1] drivers: net: cpsw: cleanup: remove unused function
Date: Thu, 24 Jul 2014 16:33:29 +0530
Message-ID: <1406199809-6720-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:36273 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755344AbaGXLDg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jul 2014 07:03:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

removing unused function as part of driver cleanup.`

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c | 11 -----------
 1 file changed, 11 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index c9e86b1..a22deb5 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1075,17 +1075,6 @@ static void cpsw_get_ethtool_stats(struct net_device *ndev,
 	}
 }
 
-static inline int __show_stat(char *buf, int maxlen, const char *name, u32 val)
-{
-	static char *leader = "........................................";
-
-	if (!val)
-		return 0;
-	else
-		return snprintf(buf, maxlen, "%s %s %10d\n", name,
-				leader + strlen(name), val);
-}
-
 static int cpsw_common_res_usage_state(struct cpsw_priv *priv)
 {
 	u32 i;
-- 
2.0.2.673.g9ab0882
