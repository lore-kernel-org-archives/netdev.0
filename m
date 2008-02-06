From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 12/14] replace __inline__ by inline in net/ipx
Date: Wed, 06 Feb 2008 10:14:17 +0100
Message-ID: <20080206092233.405496311@mai.toulouse-stg.fr.ibm.com>
References: <20080206091405.581849582@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.29.151]:39544 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760694AbYBFJ2Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2008 04:28:16 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate2.de.ibm.com (8.13.8/8.13.8) with ESMTP id m169SFKG172880
	for <netdev@vger.kernel.org>; Wed, 6 Feb 2008 09:28:15 GMT
Received: from d12av03.megacenter.de.ibm.com (d12av03.megacenter.de.ibm.com [9.149.165.213])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m169SFDQ2126062
	for <netdev@vger.kernel.org>; Wed, 6 Feb 2008 10:28:15 +0100
Received: from d12av03.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av03.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m169SEWK020058
	for <netdev@vger.kernel.org>; Wed, 6 Feb 2008 10:28:15 +0100
Content-Disposition: inline; filename=remove-__inline__-in-ipx.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

replace __inline__ by inline in net/ipx

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 net/ipx/af_ipx.c   |    2 +-
 net/ipx/ipx_proc.c |    6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)

Index: net-2.6/net/ipx/af_ipx.c
===================================================================
--- net-2.6.orig/net/ipx/af_ipx.c
+++ net-2.6/net/ipx/af_ipx.c
@@ -323,7 +323,7 @@ void ipxitf_down(struct ipx_interface *i
 	spin_unlock_bh(&ipx_interfaces_lock);
 }
 
-static __inline__ void __ipxitf_put(struct ipx_interface *intrfc)
+static inline void __ipxitf_put(struct ipx_interface *intrfc)
 {
 	if (atomic_dec_and_test(&intrfc->refcnt))
 		__ipxitf_down(intrfc);
Index: net-2.6/net/ipx/ipx_proc.c
===================================================================
--- net-2.6.orig/net/ipx/ipx_proc.c
+++ net-2.6/net/ipx/ipx_proc.c
@@ -13,7 +13,7 @@
 #include <net/tcp_states.h>
 #include <net/ipx.h>
 
-static __inline__ struct ipx_interface *ipx_get_interface_idx(loff_t pos)
+static inline struct ipx_interface *ipx_get_interface_idx(loff_t pos)
 {
 	struct ipx_interface *i;
 
@@ -107,7 +107,7 @@ static struct ipx_route *ipx_routes_next
 	return rc;
 }
 
-static __inline__ struct ipx_route *ipx_get_route_idx(loff_t pos)
+static inline struct ipx_route *ipx_get_route_idx(loff_t pos)
 {
 	struct ipx_route *r;
 
@@ -165,7 +165,7 @@ out:
 	return 0;
 }
 
-static __inline__ struct sock *ipx_get_socket_idx(loff_t pos)
+static inline struct sock *ipx_get_socket_idx(loff_t pos)
 {
 	struct sock *s = NULL;
 	struct hlist_node *node;

-- 
