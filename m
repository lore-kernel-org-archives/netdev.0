From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 10/14] replace __inline__ by inline in net/lapb
Date: Wed, 06 Feb 2008 10:14:15 +0100
Message-ID: <20080206092152.019241605@mai.toulouse-stg.fr.ibm.com>
References: <20080206091405.581849582@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.29.150]:19831 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760594AbYBFJ1f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2008 04:27:35 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.13.8/8.13.8) with ESMTP id m169RY2g012074
	for <netdev@vger.kernel.org>; Wed, 6 Feb 2008 09:27:34 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m169RYtZ2351128
	for <netdev@vger.kernel.org>; Wed, 6 Feb 2008 10:27:34 +0100
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m169RXgj005762
	for <netdev@vger.kernel.org>; Wed, 6 Feb 2008 10:27:33 +0100
Content-Disposition: inline; filename=remove-__inline__-in-lapb.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

replace __inline__ by inline in net/lapb

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 net/lapb/lapb_iface.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: net-2.6/net/lapb/lapb_iface.c
===================================================================
--- net-2.6.orig/net/lapb/lapb_iface.c
+++ net-2.6/net/lapb/lapb_iface.c
@@ -50,12 +50,12 @@ static void lapb_free_cb(struct lapb_cb 
 	kfree(lapb);
 }
 
-static __inline__ void lapb_hold(struct lapb_cb *lapb)
+static inline void lapb_hold(struct lapb_cb *lapb)
 {
 	atomic_inc(&lapb->refcnt);
 }
 
-static __inline__ void lapb_put(struct lapb_cb *lapb)
+static inline void lapb_put(struct lapb_cb *lapb)
 {
 	if (atomic_dec_and_test(&lapb->refcnt))
 		lapb_free_cb(lapb);

-- 
