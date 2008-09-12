From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RESEND][NET-NEXT PATCH 01/29] ixgbe: fix bug where using wake queue
	instead of start
Date: Thu, 11 Sep 2008 19:54:23 -0700
Message-ID: <20080912025404.6234.83037.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	akpm@linux-foundation.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.173]:16543 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754403AbYILCy1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 22:54:27 -0400
Received: by wf-out-1314.google.com with SMTP id 27so620453wfd.4
        for <netdev@vger.kernel.org>; Thu, 11 Sep 2008 19:54:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 362541a..c67211c 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3377,7 +3377,7 @@ static int __ixgbe_maybe_stop_tx(struct net_device *netdev,
 		return -EBUSY;
 
 	/* A reprieve! - use start_queue because it doesn't call schedule */
-	netif_wake_subqueue(netdev, tx_ring->queue_index);
+	netif_start_subqueue(netdev, tx_ring->queue_index);
 	++adapter->restart_queue;
 	return 0;
 }

