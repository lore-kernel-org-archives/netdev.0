From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 2/4] sky2: turn carrier off when down
Date: Sat, 07 Apr 2007 16:02:26 -0700
Message-ID: <20070407230325.617525295@linux-foundation.org>
References: <20070407230224.486666854@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:36291 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752360AbXDGXnM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Apr 2007 19:43:12 -0400
Content-Disposition: inline; filename=sky2-carrier.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Driver needs to turn off carrier when down.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- netdev-2.6.orig/drivers/net/sky2.c	2007-04-07 15:11:02.000000000 -0700
+++ netdev-2.6/drivers/net/sky2.c	2007-04-07 15:11:21.000000000 -0700
@@ -1561,6 +1561,7 @@
 
 	/* Stop more packets from being queued */
 	netif_stop_queue(dev);
+	netif_carrier_off(dev);
 
 	/* Disable port IRQ */
 	imask = sky2_read32(hw, B0_IMSK);

--

