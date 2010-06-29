From: Casey Leedom <leedom@chelsio.com>
Subject: PATCH 1/2] Remove obsolete comment about the lack of a TX Timer Callback -- which we ...
Date: Tue, 29 Jun 2010 15:53:39 -0700
Message-ID: <201006291553.39333.leedom@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:10195 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751625Ab0F2W5m convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 18:57:42 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o5TMvg2o018102
	for <netdev@vger.kernel.org>; Tue, 29 Jun 2010 15:57:42 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From fab966adc65f1b500e261867b3cb26bf35482b36 Mon Sep 17 00:00:00 2001
From: Casey Leedom <leedom@chelsio.com>
Date: Tue, 29 Jun 2010 15:14:38 -0700
Subject: [PATCH 1/2] Remove obsolete comment about the lack of a TX Timer Callback -- which we
 now _do_ have ...


Signed-off-by: Casey Leedom <leedom@chelsio.com>
---
 drivers/net/cxgb4vf/sge.c |   13 +------------
 1 files changed, 1 insertions(+), 12 deletions(-)

diff --git a/drivers/net/cxgb4vf/sge.c b/drivers/net/cxgb4vf/sge.c
index f857d20..5c4a81d 100644
--- a/drivers/net/cxgb4vf/sge.c
+++ b/drivers/net/cxgb4vf/sge.c
@@ -1301,18 +1301,7 @@ int t4vf_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 		 * wait for acks to really free up the data the extra memory
 		 * is even less.  On the positive side we run the destructors
 		 * on the sending CPU rather than on a potentially different
-		 * completing CPU, usually a good thing.  We also run them
-		 * without holding our TX queue lock, unlike what
-		 * reclaim_completed_tx() would otherwise do.
-		 *
-		 * XXX Actually the above is somewhat incorrect since we don't
-		 * XXX yet have a periodic timer which reclaims TX Descriptors.
-		 * XXX What's our plan for this?
-		 * XXX
-		 * XXX Also, we don't currently have a TX Queue lock but
-		 * XXX that may be the result of not having any current
-		 * XXX asynchronous path for reclaiming completed TX
-		 * XXX Descriptors ...
+		 * completing CPU, usually a good thing.
 		 *
 		 * Run the destructor before telling the DMA engine about the
 		 * packet to make sure it doesn't complete and get freed
-- 
1.7.0.4

