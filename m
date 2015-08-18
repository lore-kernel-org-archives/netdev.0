From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH 01/21] net: veth: enable noqueue operation by default
Date: Tue, 18 Aug 2015 10:30:29 +0200
Message-ID: <1439886649-24166-2-git-send-email-phil@nwl.cc>
References: <1439886649-24166-1-git-send-email-phil@nwl.cc>
Cc: brouer@redhat.com, davem@davemloft.net,
	Pavel Emelyanov <xemul@openvz.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:59568 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751119AbbHRIav (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2015 04:30:51 -0400
In-Reply-To: <1439886649-24166-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
Cc: Pavel Emelyanov <xemul@openvz.org>
---
 drivers/net/veth.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 343592c..0ef4a5a 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -306,6 +306,7 @@ static void veth_setup(struct net_device *dev)
 
 	dev->priv_flags &= ~IFF_TX_SKB_SHARING;
 	dev->priv_flags |= IFF_LIVE_ADDR_CHANGE;
+	dev->priv_flags |= IFF_NO_QUEUE;
 
 	dev->netdev_ops = &veth_netdev_ops;
 	dev->ethtool_ops = &veth_ethtool_ops;
-- 
2.1.2
