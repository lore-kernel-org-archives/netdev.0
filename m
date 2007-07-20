From: Masakazu Mokuno <mokuno@sm.sony.co.jp>
Subject: [PATCH 8/10] ps3: removed calling netif_poll_enable() in open()
Date: Fri, 20 Jul 2007 17:34:07 +0900
Message-ID: <20070720173316.679E.MOKUNO@sm.sony.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cbe-oss-dev@ozlabs.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from NS5.Sony.CO.JP ([137.153.0.45]:50906 "EHLO ns5.sony.co.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933833AbXGTIeJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jul 2007 04:34:09 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Removed use of netif_poll_enable() in open function.

Signed-off-by: Masakazu Mokuno <mokuno@sm.sony.co.jp>
---
 drivers/net/ps3_gelic_net.c |    1 -
 1 file changed, 1 deletion(-)

--- a/drivers/net/ps3_gelic_net.c
+++ b/drivers/net/ps3_gelic_net.c
@@ -1134,7 +1134,6 @@ static int gelic_net_open(struct net_dev
 
 	netif_start_queue(netdev);
 	netif_carrier_on(netdev);
-	netif_poll_enable(netdev);
 
 	return 0;
 

--
Masakazu MOKUNO

