From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net-next PATCH v2 2/3] drivers: net: cpsw: remove redundancy check
Date: Wed, 9 Jul 2014 12:44:09 +0530
Message-ID: <1404890050-4020-3-git-send-email-mugunthanvnm@ti.com>
References: <1404890050-4020-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <linux-api@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:40256 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754498AbaGIHOY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jul 2014 03:14:24 -0400
In-Reply-To: <1404890050-4020-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In cpsw_set_coalesce, rx_coalesce_usecs is already checked before
calling this function, so removing redundancy check.

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index b988d16..a6117e6 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -884,9 +884,6 @@ static int cpsw_set_coalesce(struct net_device *ndev,
 	u32 addnl_dvdr = 1;
 	u32 coal_intvl = 0;
 
-	if (!coal->rx_coalesce_usecs)
-		return -EINVAL;
-
 	coal_intvl = coal->rx_coalesce_usecs;
 
 	int_ctrl =  readl(&priv->wr_regs->int_control);
-- 
2.0.0.390.gcb682f8
