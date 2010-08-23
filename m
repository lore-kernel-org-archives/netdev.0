From: Anton Blanchard <anton@samba.org>
Subject: [patch 12/20] ibmveth: Remove redundant function prototypes
Date: Mon, 23 Aug 2010 10:09:42 +1000
Message-ID: <20100823001239.417587777@samba.org>
References: <20100823000930.546065833@samba.org>
Cc: netdev@vger.kernel.org
To: brking@linux.vnet.ibm.com, santil@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:51852 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751809Ab0HWA2w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Aug 2010 20:28:52 -0400
Content-Disposition: inline; filename=veth_remove_prototype
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These functions appear before their use, so we can remove the redundant
prototypes.

Signed-off-by: Anton Blanchard <anton@samba.org>
---

Index: net-next-2.6/drivers/net/ibmveth.c
===================================================================
--- net-next-2.6.orig/drivers/net/ibmveth.c	2010-08-23 08:52:32.113625155 +1000
+++ net-next-2.6/drivers/net/ibmveth.c	2010-08-23 08:52:32.523596050 +1000
@@ -78,16 +78,10 @@
 #define ibmveth_assert(expr)
 #endif
 
-static int ibmveth_open(struct net_device *dev);
-static int ibmveth_close(struct net_device *dev);
-static int ibmveth_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd);
-static int ibmveth_poll(struct napi_struct *napi, int budget);
-static int ibmveth_start_xmit(struct sk_buff *skb, struct net_device *dev);
-static void ibmveth_set_multicast_list(struct net_device *dev);
-static int ibmveth_change_mtu(struct net_device *dev, int new_mtu);
 static irqreturn_t ibmveth_interrupt(int irq, void *dev_instance);
 static void ibmveth_rxq_harvest_buffer(struct ibmveth_adapter *adapter);
 static unsigned long ibmveth_get_desired_dma(struct vio_dev *vdev);
+
 static struct kobj_type ktype_veth_pool;
 
 


