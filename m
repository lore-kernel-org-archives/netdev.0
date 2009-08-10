From: Wolfram Sang <w.sang@pengutronix.de>
Subject: [PATCH] include/netdevice.h: fix nanodoc mismatch
Date: Mon, 10 Aug 2009 13:04:49 +0200
Message-ID: <1249902289-25798-1-git-send-email-w.sang@pengutronix.de>
Cc: trivial@kernel.org, Wolfram Sang <w.sang@pengutronix.de>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:60019 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751093AbZHJLEu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2009 07:04:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

nanodoc was missing an ndo_-prefix.

Signed-off-by: Wolfram Sang <w.sang@pengutronix.de>
Cc: "David S. Miller" <davem@davemloft.net>
---
 include/linux/netdevice.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index d4a4d98..277f1c2 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -557,7 +557,7 @@ struct netdev_queue {
  *	Callback uses when the transmitter has not made any progress
  *	for dev->watchdog ticks.
  *
- * struct net_device_stats* (*get_stats)(struct net_device *dev);
+ * struct net_device_stats* (*ndo_get_stats)(struct net_device *dev);
  *	Called when a user wants to get the network device usage
  *	statistics. If not defined, the counters in dev->stats will
  *	be used.
-- 
1.6.3.1

