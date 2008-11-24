From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] netdev: add HAVE_NET_DEVICE_OPS
Date: Mon, 24 Nov 2008 10:39:47 -0800
Message-ID: <20081124103947.32307e7b@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:46601 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751586AbYKXSju (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Nov 2008 13:39:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As a concession to vendors who have to deal with one source for different
kernel versions, add a HAVE_NET_DEVICE_OPS so they don't end up hard
coding ifdef against kernel version.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/include/linux/netdevice.h	2008-11-23 08:49:59.000000000 -0800
+++ b/include/linux/netdevice.h	2008-11-23 08:50:16.000000000 -0800
@@ -545,6 +545,7 @@ struct netdev_queue {
  *
  * void (*ndo_poll_controller)(struct net_device *dev);
  */
+#define HAVE_NET_DEVICE_OPS
 struct net_device_ops {
 	int			(*ndo_init)(struct net_device *dev);
 	void			(*ndo_uninit)(struct net_device *dev);
