From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH net-next] net: iseries_veth: Use is_unicast_ether_addr helper
Date: Mon,  4 Jul 2011 11:52:03 +0200
Message-ID: <1309773123-24049-1-git-send-email-tklauser@distanz.ch>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.zhaw.ch ([160.85.104.50]:42739 "EHLO mx1.zhaw.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754151Ab1GDJwJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jul 2011 05:52:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/iseries_veth.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/iseries_veth.c b/drivers/net/iseries_veth.c
index 242bf52..53dd39e 100644
--- a/drivers/net/iseries_veth.c
+++ b/drivers/net/iseries_veth.c
@@ -1182,7 +1182,7 @@ static int veth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct veth_port *port = netdev_priv(dev);
 	HvLpIndexMap lpmask;
 
-	if (! (frame[0] & 0x01)) {
+	if (is_unicast_ether_addr(frame)) {
 		/* unicast packet */
 		HvLpIndex rlp = frame[5];
 
-- 
1.7.5.4

