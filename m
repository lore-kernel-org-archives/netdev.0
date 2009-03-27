From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 17/30] netdev: smc-ultra fix netpoll
Date: Thu, 26 Mar 2009 18:11:31 -0700
Message-ID: <20090327011256.174148808@linux-foundation.org>
References: <20090327011114.169107105@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:49171 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759385AbZC0Ba3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Mar 2009 21:30:29 -0400
Content-Disposition: inline; filename=smc-ultra.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net_device_ops conversion left the wrong poll_controller hook.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/smc-ultra.c	2009-03-26 15:59:56.000000000 -0700
+++ b/drivers/net/smc-ultra.c	2009-03-26 16:09:01.923594547 -0700
@@ -196,7 +196,7 @@ static const struct net_device_ops ultra
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_change_mtu		= eth_change_mtu,
 #ifdef CONFIG_NET_POLL_CONTROLLER
-	.ndo_poll_controller 	= ei_poll,
+	.ndo_poll_controller 	= ultra_poll,
 #endif
 };
 


