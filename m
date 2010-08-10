From: "John W. Linville" <linville@tuxdriver.com>
Subject: [PATCH] net: make netpoll_rx return bool for !CONFIG_NETPOLL
Date: Tue, 10 Aug 2010 15:44:47 -0400
Message-ID: <1281469487-8946-1-git-send-email-linville@tuxdriver.com>
Cc: davem@davemloft.net, "John W. Linville" <linville@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:58598 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751662Ab0HJTon (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Aug 2010 15:44:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"netpoll: Use 'bool' for netpoll_rx() return type." missed the case when
CONFIG_NETPOLL is disabled.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
 include/linux/netpoll.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/netpoll.h b/include/linux/netpoll.h
index 413742c..791d510 100644
--- a/include/linux/netpoll.h
+++ b/include/linux/netpoll.h
@@ -122,7 +122,7 @@ static inline int netpoll_tx_running(struct net_device *dev)
 }
 
 #else
-static inline int netpoll_rx(struct sk_buff *skb)
+static inline bool netpoll_rx(struct sk_buff *skb)
 {
 	return 0;
 }
-- 
1.7.2.1

