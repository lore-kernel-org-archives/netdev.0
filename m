From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 1/5] mv643xx_eth: fix variable shadowing sparse warning
Date: Wed, 6 May 2009 15:00:59 +0200
Message-ID: <20090506130059.GF24429@mail.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:40430 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753716AbZEFMyP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 08:54:15 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index a400d71..352c772 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -1807,7 +1807,6 @@ static void mv643xx_eth_program_multicast_filter(struct net_device *dev)
 	if (dev->flags & (IFF_PROMISC | IFF_ALLMULTI)) {
 		int port_num;
 		u32 accept;
-		int i;
 
 oom:
 		port_num = mp->port_num;
-- 
1.5.6.4
