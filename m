From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH] xen-netfront: correct MAX_TX_TARGET calculation.
Date: Thu, 26 Jan 2012 17:23:23 +0000
Message-ID: <1327598603-16398-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: jeremy@goop.org, konrad.wilk@oracle.com,
	xen-devel@lists.xensource.com, ian.campbell@citrix.com,
	Wei Liu <wei.liu2@citrix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:55040 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752435Ab2AZRXZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jan 2012 12:23:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netfront.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 38f9c95..01f589d 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -68,7 +68,7 @@ struct netfront_cb {
 
 #define NET_TX_RING_SIZE __CONST_RING_SIZE(xen_netif_tx, PAGE_SIZE)
 #define NET_RX_RING_SIZE __CONST_RING_SIZE(xen_netif_rx, PAGE_SIZE)
-#define TX_MAX_TARGET min_t(int, NET_RX_RING_SIZE, 256)
+#define TX_MAX_TARGET min_t(int, NET_TX_RING_SIZE, 256)
 
 struct netfront_stats {
 	u64			rx_packets;
-- 
1.7.8.3
