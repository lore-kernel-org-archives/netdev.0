From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 3/9][NETNS][IPV6] make ipv6 structure for netns
Date: Fri, 04 Jan 2008 12:12:29 +0100
Message-ID: <20080104111428.553329528@localhost.localdomain>
References: <20080104111226.776105484@localhost.localdomain>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.uk.ibm.com ([195.212.29.141]:12778 "EHLO
	mtagate8.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751802AbYADLXY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2008 06:23:24 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate8.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m04BNMxx538654
	for <netdev@vger.kernel.org>; Fri, 4 Jan 2008 11:23:22 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m04BNM6r5001382
	for <netdev@vger.kernel.org>; Fri, 4 Jan 2008 11:23:22 GMT
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m04BN5bs028902
	for <netdev@vger.kernel.org>; Fri, 4 Jan 2008 11:23:05 GMT
Content-Disposition: inline; filename=sysctl/make-ipv6-for-netns.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Like the ipv4 part, this patch adds an ipv6 structure in the net structure
to aggregate the different resources to make ipv6 per namespace.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 include/net/net_namespace.h |    2 ++
 include/net/netns/ipv6.h    |   10 ++++++++++
 2 files changed, 12 insertions(+)

Index: net-2.6.25/include/net/net_namespace.h
===================================================================
--- net-2.6.25.orig/include/net/net_namespace.h
+++ net-2.6.25/include/net/net_namespace.h
@@ -11,6 +11,7 @@
 #include <net/netns/unix.h>
 #include <net/netns/packet.h>
 #include <net/netns/ipv4.h>
+#include <net/netns/ipv6.h>
 
 struct proc_dir_entry;
 struct net_device;
@@ -48,6 +49,7 @@ struct net {
 	struct netns_packet	packet;
 	struct netns_unix	unx;
 	struct netns_ipv4	ipv4;
+	struct netns_ipv6	ipv6;
 };
 
 #ifdef CONFIG_NET
Index: net-2.6.25/include/net/netns/ipv6.h
===================================================================
--- /dev/null
+++ net-2.6.25/include/net/netns/ipv6.h
@@ -0,0 +1,10 @@
+/*
+ * ipv6 in net namespaces
+ */
+
+#ifndef __NETNS_IPV6_H__
+#define __NETNS_IPV6_H__
+
+struct netns_ipv6 {
+};
+#endif

-- 
