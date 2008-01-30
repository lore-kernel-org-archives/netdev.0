From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: rtl8150: use default MTU of 1500
Date: Wed, 30 Jan 2008 20:37:42 +0100
Message-ID: <20080130193742.GA13631@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Petko Manolov <petkan@nucleusys.com>
To: netdev@vger.kernel.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:50003 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765349AbYA3UGm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2008 15:06:42 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The RTL8150 driver uses an MTU of 1540 by default, which causes a
bunch of problems -- it prevents booting from NFS root, for one.

Signed-off-by: Lennert Buytenhek <buytenh@wantstofly.org>
Cc: Petko Manolov <petkan@nucleusys.com>

--- linux-2.6.24-git7.orig/drivers/net/usb/rtl8150.c	2008-01-24 23:58:37.000000000 +0100
+++ linux-2.6.24-git7/drivers/net/usb/rtl8150.c	2008-01-30 20:29:00.000000000 +0100
@@ -925,9 +925,8 @@
 	netdev->hard_start_xmit = rtl8150_start_xmit;
 	netdev->set_multicast_list = rtl8150_set_multicast;
 	netdev->set_mac_address = rtl8150_set_mac_address;
 	netdev->get_stats = rtl8150_netdev_stats;
-	netdev->mtu = RTL8150_MTU;
 	SET_ETHTOOL_OPS(netdev, &ops);
 	dev->intr_interval = 100;	/* 100ms */
 
 	if (!alloc_all_urbs(dev)) {
