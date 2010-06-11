From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 2/8] bridge: Remove redundant npinfo NULL setting
Date: Fri, 11 Jun 2010 12:12:43 +1000
Message-ID: <E1OMtjf-0006OS-P3@gondolin.me.apana.org.au>
References: <20100611021142.GA24490@gondor.apana.org.au>
To: "Michael S. Tsirkin" <mst@redhat.com>,
	Qianfeng Zhang <frzhang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	WANG Cong <amwang@redhat.com>,
	Stephen He
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:38008 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754745Ab0FKCMp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jun 2010 22:12:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bridge: Remove redundant npinfo NULL setting

Now that netpoll always zaps npinfo we no longer needs to do it
in bridge.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/bridge/br_device.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index eedf2c9..dce0611 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -231,7 +231,6 @@ void br_netpoll_cleanup(struct net_device *dev)
 	struct net_bridge_port *p, *n;
 	const struct net_device_ops *ops;
 
-	br->dev->npinfo = NULL;
 	list_for_each_entry_safe(p, n, &br->port_list, list) {
 		if (p->dev) {
 			ops = p->dev->netdev_ops;
