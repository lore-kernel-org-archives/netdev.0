From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 03/14] replace __inline__ by inline in net/appletalk
Date: Wed, 06 Feb 2008 10:14:08 +0100
Message-ID: <20080206092105.701951200@mai.toulouse-stg.fr.ibm.com>
References: <20080206091405.581849582@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.29.154]:27494 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760350AbYBFJ0m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2008 04:26:42 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate5.de.ibm.com (8.13.8/8.13.8) with ESMTP id m169Qf78384622
	for <netdev@vger.kernel.org>; Wed, 6 Feb 2008 09:26:41 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m169QfLW2293884
	for <netdev@vger.kernel.org>; Wed, 6 Feb 2008 10:26:41 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m169QeNs000811
	for <netdev@vger.kernel.org>; Wed, 6 Feb 2008 10:26:41 +0100
Content-Disposition: inline; filename=remove-__inline__-in-appletalk.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

replace __inline__ by inline in net/appletalk

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 net/appletalk/atalk_proc.c |    6 +++---
 net/appletalk/ddp.c        |    2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

Index: net-2.6/net/appletalk/atalk_proc.c
===================================================================
--- net-2.6.orig/net/appletalk/atalk_proc.c
+++ net-2.6/net/appletalk/atalk_proc.c
@@ -16,7 +16,7 @@
 #include <linux/atalk.h>
 
 
-static __inline__ struct atalk_iface *atalk_get_interface_idx(loff_t pos)
+static inline struct atalk_iface *atalk_get_interface_idx(loff_t pos)
 {
 	struct atalk_iface *i;
 
@@ -77,7 +77,7 @@ out:
 	return 0;
 }
 
-static __inline__ struct atalk_route *atalk_get_route_idx(loff_t pos)
+static inline struct atalk_route *atalk_get_route_idx(loff_t pos)
 {
 	struct atalk_route *r;
 
@@ -144,7 +144,7 @@ out:
 	return 0;
 }
 
-static __inline__ struct sock *atalk_get_socket_idx(loff_t pos)
+static inline struct sock *atalk_get_socket_idx(loff_t pos)
 {
 	struct sock *s;
 	struct hlist_node *node;
Index: net-2.6/net/appletalk/ddp.c
===================================================================
--- net-2.6.orig/net/appletalk/ddp.c
+++ net-2.6/net/appletalk/ddp.c
@@ -1265,7 +1265,7 @@ static int atalk_getname(struct socket *
 }
 
 #if defined(CONFIG_IPDDP) || defined(CONFIG_IPDDP_MODULE)
-static __inline__ int is_ip_over_ddp(struct sk_buff *skb)
+static inline int is_ip_over_ddp(struct sk_buff *skb)
 {
 	return skb->data[12] == 22;
 }

-- 
