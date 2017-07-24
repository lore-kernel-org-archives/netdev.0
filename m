From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 1/6] netvsc: remove bogus rtnl_unlock
Date: Mon, 24 Jul 2017 10:57:25 -0700
Message-ID: <20170724175730.31806-2-sthemmin@microsoft.com>
References: <20170724175730.31806-1-sthemmin@microsoft.com>
Cc: devel@linuxdriverproject.org, netdev@vger.kernel.org
To: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:34096 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754320AbdGXR5k (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 13:57:40 -0400
Received: by mail-pg0-f41.google.com with SMTP id 123so60199816pgj.1
        for <netdev@vger.kernel.org>; Mon, 24 Jul 2017 10:57:40 -0700 (PDT)
In-Reply-To: <20170724175730.31806-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove accidental rtnl_unlock from earlier testing.

Fixes: 3962981f4822 ("netvsc: add rtnl annotations in rndis")
Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index a164981c15f7..1238600d717e 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -1548,7 +1548,6 @@ static int netvsc_probe(struct hv_device *dev,
 
 	netif_set_real_num_tx_queues(net, nvdev->num_chn);
 	netif_set_real_num_rx_queues(net, nvdev->num_chn);
-	rtnl_unlock();
 
 	netdev_lockdep_set_classes(net);
 
-- 
2.11.0
