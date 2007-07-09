From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 11/12] sky2: remove some leftover debug messages
Date: Mon, 09 Jul 2007 15:33:43 -0700
Message-ID: <20070709223453.615704448@linux-foundation.org>
References: <20070709223332.966231494@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:51770 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754654AbXGIWo6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2007 18:44:58 -0400
Content-Disposition: inline; filename=sky2-cleanup.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eliminate extra debug messages

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


---
 drivers/net/sky2.c |    5 -----
 1 file changed, 5 deletions(-)

--- a/drivers/net/sky2.c	2007-07-09 15:30:14.000000000 -0700
+++ b/drivers/net/sky2.c	2007-07-09 15:30:14.000000000 -0700
@@ -2058,8 +2058,6 @@ static struct sk_buff *receive_new(struc
 	struct sk_buff *skb, *nskb;
 	unsigned hdr_space = sky2->rx_data_size;
 
-	pr_debug(PFX "receive new length=%d\n", length);
-
 	/* Don't be tricky about reusing pages (yet) */
 	nskb = sky2_rx_alloc(sky2);
 	if (unlikely(!nskb))
@@ -2728,8 +2726,6 @@ static void sky2_restart(struct work_str
 	struct net_device *dev;
 	int i, err;
 
-	dev_dbg(&hw->pdev->dev, "restarting\n");
-
 	del_timer_sync(&hw->idle_timer);
 
 	rtnl_lock();

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

