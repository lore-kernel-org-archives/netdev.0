From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net-next PATCH 2/3] drivers: net: cpsw: remove redundancy check
Date: Tue, 8 Jul 2014 14:27:40 +0530
Message-ID: <1404809861-7040-3-git-send-email-mugunthanvnm@ti.com>
References: <1404809861-7040-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <linux-api@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1404809861-7040-1-git-send-email-mugunthanvnm@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
