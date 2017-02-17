From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] netvsc: fix typo on statistics
Date: Fri, 17 Feb 2017 11:36:20 -0800
Message-ID: <20170217193620.12175-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Simon Xiao <sixaio@microsoft.com>,
        Simon Xiao <sixiao@microsoft.com>,
        Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:36315 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755655AbdBQTgY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 14:36:24 -0500
Received: by mail-pg0-f53.google.com with SMTP id v184so17827694pgv.3
        for <netdev@vger.kernel.org>; Fri, 17 Feb 2017 11:36:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Xiao <sixaio@microsoft.com>

Return the correct tx_errors stats in netvsc.

Reviewed-by: Haiyang Zhang <haiyangz@microsoft.com>
Signed-off-by: Simon Xiao <sixiao@microsoft.com>
Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 425285f36595..2d3cdb026a99 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -920,7 +920,7 @@ static void netvsc_get_stats64(struct net_device *net,
 	}
 
 	t->tx_dropped	= net->stats.tx_dropped;
-	t->tx_errors	= net->stats.tx_dropped;
+	t->tx_errors	= net->stats.tx_errors;
 
 	t->rx_dropped	= net->stats.rx_dropped;
 	t->rx_errors	= net->stats.rx_errors;
-- 
2.11.0
