From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 2/4] sky2: turn carrier off when down
Date: Sat, 07 Apr 2007 16:42:07 -0700
Message-ID: <20070407234235.799379023@linux-foundation.org>
References: <20070407234205.348565140@linux-foundation.org>
Cc: stable@kernel.org, netdev@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:36306 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966002AbXDGXo1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Apr 2007 19:44:27 -0400
Content-Disposition: inline; filename=sky2-carrier.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Driver needs to turn off carrier when down.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- linux-2.6.20.y.orig/drivers/net/sky2.c	2007-04-07 15:36:05.000000000 -0700
+++ linux-2.6.20.y/drivers/net/sky2.c	2007-04-07 15:54:42.000000000 -0700
@@ -1506,6 +1506,7 @@
 
 	/* Stop more packets from being queued */
 	netif_stop_queue(dev);
+	netif_carrier_off(dev);
 
 	/* Disable port IRQ */
 	imask = sky2_read32(hw, B0_IMSK);

--

