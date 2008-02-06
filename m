From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 08/14] replace __inline__ by inline in net/x25
Date: Wed, 06 Feb 2008 10:14:13 +0100
Message-ID: <20080206092143.950791555@mai.toulouse-stg.fr.ibm.com>
References: <20080206091405.581849582@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.uk.ibm.com ([195.212.29.139]:25947 "EHLO
	mtagate6.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760767AbYBFJ2d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2008 04:28:33 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate6.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m169RIUe525452
	for <netdev@vger.kernel.org>; Wed, 6 Feb 2008 09:27:18 GMT
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m169RHLZ1830946
	for <netdev@vger.kernel.org>; Wed, 6 Feb 2008 09:27:17 GMT
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m169RE45026607
	for <netdev@vger.kernel.org>; Wed, 6 Feb 2008 09:27:14 GMT
Content-Disposition: inline; filename=remove-__inline__-in-x25.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

replace __inline__ by inline in net/x25

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 net/x25/x25_proc.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

Index: net-2.6/net/x25/x25_proc.c
===================================================================
--- net-2.6.orig/net/x25/x25_proc.c
+++ net-2.6/net/x25/x25_proc.c
@@ -25,7 +25,7 @@
 #include <net/x25.h>
 
 #ifdef CONFIG_PROC_FS
-static __inline__ struct x25_route *x25_get_route_idx(loff_t pos)
+static inline struct x25_route *x25_get_route_idx(loff_t pos)
 {
 	struct list_head *route_entry;
 	struct x25_route *rt = NULL;
@@ -93,7 +93,7 @@ out:
 	return 0;
 }
 
-static __inline__ struct sock *x25_get_socket_idx(loff_t pos)
+static inline struct sock *x25_get_socket_idx(loff_t pos)
 {
 	struct sock *s;
 	struct hlist_node *node;
@@ -170,7 +170,7 @@ out:
 	return 0;
 }
 
-static __inline__ struct x25_forward *x25_get_forward_idx(loff_t pos)
+static inline struct x25_forward *x25_get_forward_idx(loff_t pos)
 {
 	struct x25_forward *f;
 	struct list_head *entry;

-- 
