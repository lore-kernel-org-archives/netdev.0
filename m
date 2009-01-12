From: Paul Bolle <pebolle@tiscali.nl>
Subject: [i4l] minor cleanups
Date: Mon, 12 Jan 2009 13:37:38 +0100
Message-ID: <1231763858.7132.8.camel@test.thuisdomein>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out1.tiscali.nl ([195.241.79.176]:59301 "EHLO
	smtp-out1.tiscali.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751729AbZALMyw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2009 07:54:52 -0500
Received: from [212.123.169.34] (helo=[192.168.1.42])
	by smtp-out1.tiscali.nl with esmtp
	id 1LMM31-0003Vx-Oh
	for <netdev@vger.kernel.org>; Mon, 12 Jan 2009 13:37:39 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Minor cleanups, either made possible or obvious after commit d700555 (I4l:
convert to net_device_ops).

Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
---
Sent only to netdev@vger.kernel.org (and not also to
isdn4linux@listserv.isdn4linux.de) because an earlier ISDN patch I wrote
only got a response from this list (and this patch is NETWORKING related
anyway).
---
diff --git a/drivers/isdn/i4l/isdn_net.c b/drivers/isdn/i4l/isdn_net.c
index 7c5f970..ecc92c8 100644
--- a/drivers/isdn/i4l/isdn_net.c
+++ b/drivers/isdn/i4l/isdn_net.c
@@ -2513,7 +2513,6 @@ static const struct net_device_ops isdn_netdev_ops = {
 	.ndo_stop	      = isdn_net_close,
 	.ndo_do_ioctl	      = isdn_net_ioctl,
 
-	.ndo_validate_addr    = NULL,
 	.ndo_start_xmit	      = isdn_net_start_xmit,
 	.ndo_get_stats	      = isdn_net_get_stats,
 	.ndo_tx_timeout	      = isdn_net_tx_timeout,
@@ -2528,12 +2527,8 @@ static void _isdn_setup(struct net_device *dev)
 
 	ether_setup(dev);
 
-	dev->flags = IFF_NOARP | IFF_POINTOPOINT;
 	/* Setup the generic properties */
-	dev->mtu = 1500;
 	dev->flags = IFF_NOARP|IFF_POINTOPOINT;
-	dev->type = ARPHRD_ETHER;
-	dev->addr_len = ETH_ALEN;
 	dev->header_ops = NULL;
 	dev->netdev_ops = &isdn_netdev_ops;
 


