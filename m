From: Santiago Leon <santil@linux.vnet.ibm.com>
Subject: [patch 13/21] ibmveth: Remove redundant function prototypes
Date: Fri, 03 Sep 2010 23:29:08 -0500
Message-ID: <20100904042908.2655.3552.sendpatchset@jupiter1-ltc-lp2.austin.ibm.com>
References: <20100904042758.2655.8093.sendpatchset@jupiter1-ltc-lp2.austin.ibm.com>
Cc: brking@linux.vnet.ibm.com,
	Santiago Leon <santil@linux.vnet.ibm.com>, anton@samba.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:43817 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752462Ab0IDE3h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Sep 2010 00:29:37 -0400
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e33.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o844OdbD002308
	for <netdev@vger.kernel.org>; Fri, 3 Sep 2010 22:24:39 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o844Ta2L150672
	for <netdev@vger.kernel.org>; Fri, 3 Sep 2010 22:29:36 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o844TakF001618
	for <netdev@vger.kernel.org>; Fri, 3 Sep 2010 22:29:36 -0600
In-Reply-To: <20100904042758.2655.8093.sendpatchset@jupiter1-ltc-lp2.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These functions appear before their use, so we can remove the redundant
prototypes.

Signed-off-by: Anton Blanchard <anton@samba.org>
Signed-off-by: Santiago Leon <santil@linux.vnet.ibm.com>
---

Index: net-next-2.6/drivers/net/ibmveth.c
===================================================================
--- net-next-2.6.orig//drivers/net/ibmveth.c	2010-09-03 22:19:08.000000000 -0500
+++ net-next-2.6/drivers/net/ibmveth.c	2010-09-03 22:19:09.000000000 -0500
@@ -79,16 +79,10 @@
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
 
 
