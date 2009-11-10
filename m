From: Benjamin LaHaise <bcrl@lhnet.ca>
Subject: [PATCH] add HAVE_UNREGISTER_NETDEV_QUEUE define for out-of-tree modules
Date: Tue, 10 Nov 2009 17:00:04 -0500
Message-ID: <20091110220004.GT21704@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:54037 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751213AbZKJWAA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Nov 2009 17:00:00 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I have an out of tree network driver (GPL'd) that would like to make use of 
the unregister_netdevice_queue interface for bulk unregister of devices.  
Add a #define HAVE_UNREGISTER_NETDEV_QUEUE to allow the source to detect 
that the kernel supports this.

		-ben

Signed-off-by: Benjamin LaHaise <bcrl@lhnet.ca
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 465add6..f9e8e0e 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1117,6 +1117,7 @@ extern int		dev_close(struct net_device *dev);
 extern void		dev_disable_lro(struct net_device *dev);
 extern int		dev_queue_xmit(struct sk_buff *skb);
 extern int		register_netdevice(struct net_device *dev);
+#define HAVE_UNREGISTER_NETDEV_QUEUE
 extern void		unregister_netdevice_queue(struct net_device *dev,
 						   struct list_head *head);
 extern void		unregister_netdevice_many(struct list_head *head);
