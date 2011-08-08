From: Tom Herbert <therbert@google.com>
Subject: [RFC PATCH v2 3/9] net: Add netdev interfaces for recording sends
 and completions
Date: Sun, 7 Aug 2011 21:48:01 -0700 (PDT)
Message-ID: <alpine.DEB.2.00.1108072143360.13386@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:12795 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750899Ab1HHEsH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2011 00:48:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add interfaces for driver to call for recording number of packets and
bytes at send time an transmit completion.  Also, a function to "reset"
a queue.  These will be used by Byte Queue Limits.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/netdevice.h |   26 ++++++++++++++++++++++++++
 1 files changed, 26 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 4115b4d..74e8862 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1910,6 +1910,32 @@ static inline int netif_xmit_frozen_or_stopped(const struct netdev_queue *dev_qu
 	return dev_queue->state & QUEUE_STATE_ANY_XOFF_OR_FROZEN;
 }
 
+static inline void netdev_tx_sent_queue(struct netdev_queue *dev_queue,
+					unsigned int pkts, unsigned int bytes)
+{
+}
+
+static inline void netdev_sent_queue(struct net_device *dev,
+				     unsigned int pkts, unsigned int bytes)
+{
+}
+
+static inline void netdev_tx_completed_queue(struct netdev_queue *dev_queue,
+					     unsigned pkts, unsigned bytes)
+{
+}
+
+static inline void netdev_completed_queue(struct net_device *dev,
+					  unsigned pkts, unsigned bytes)
+{
+}
+
+static inline void netdev_tx_reset_queue(struct netdev_queue *q)
+{
+}
+
+static inline void netdev_reset_queue(struct net_device *dev_queue)
+{
 }
 
 /**
-- 
1.7.3.1

