From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] netdevice: Correct function pointer name in comment
Date: Mon, 10 Aug 2009 13:28:09 +0200
Message-ID: <1249903689-6429-1-git-send-email-tklauser@distanz.ch>
Cc: netdev@vger.kernel.org, Tobias Klauser <tklauser@distanz.ch>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.zhaw.ch ([160.85.104.51]:53173 "EHLO mx2.zhaw.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753048AbZHJLfO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Aug 2009 07:35:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function pointer in struct net_device_ops is called ndo_get_stats.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
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
1.6.0.4

