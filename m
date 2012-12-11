From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] tun: allow setting ethernet addresss while running
Date: Mon, 10 Dec 2012 17:16:00 -0800
Message-ID: <1355188560-8388-1-git-send-email-shemminger@vyatta.com>
Cc: netdev@vger.kernel.org, jasowang@redhat.com,
	Stephen Hemminger <shemminger@vyatta.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:57096 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751402Ab2LKBRh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Dec 2012 20:17:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a pure software device, and ok with live address change.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
---
 drivers/net/tun.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 14a0454..2ac2164 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -849,6 +849,7 @@ static void tun_net_init(struct net_device *dev)
 		/* Ethernet TAP Device */
 		ether_setup(dev);
 		dev->priv_flags &= ~IFF_TX_SKB_SHARING;
+		dev->priv_flags |= IFF_LIVE_ADDR_CHANGE;
 
 		eth_hw_addr_random(dev);
 
-- 
1.7.10.4
