From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 04/14] replace __inline__ by inline in net/atm
Date: Wed, 06 Feb 2008 10:14:09 +0100
Message-ID: <20080206092114.438355112@mai.toulouse-stg.fr.ibm.com>
References: <20080206091405.581849582@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.29.152]:1417 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760386AbYBFJ0x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2008 04:26:53 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate3.de.ibm.com (8.13.8/8.13.8) with ESMTP id m169Qnei192672
	for <netdev@vger.kernel.org>; Wed, 6 Feb 2008 09:26:49 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m169QmV92351300
	for <netdev@vger.kernel.org>; Wed, 6 Feb 2008 10:26:48 +0100
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m169QmN7004581
	for <netdev@vger.kernel.org>; Wed, 6 Feb 2008 10:26:48 +0100
Content-Disposition: inline; filename=remove-__inline__-in-atm.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

replace __inline__ by inline in net/atm

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 net/atm/lec.c       |    4 ++--
 net/atm/resources.c |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

Index: net-2.6/net/atm/lec.c
===================================================================
--- net-2.6.orig/net/atm/lec.c
+++ net-2.6/net/atm/lec.c
@@ -226,8 +226,8 @@ static int lec_open(struct net_device *d
 	return 0;
 }
 
-static __inline__ void
-lec_send(struct atm_vcc *vcc, struct sk_buff *skb, struct lec_priv *priv)
+static inline void lec_send(struct atm_vcc *vcc, struct sk_buff *skb,
+			    struct lec_priv *priv)
 {
 	ATM_SKB(skb)->vcc = vcc;
 	ATM_SKB(skb)->atm_options = vcc->atm_options;
Index: net-2.6/net/atm/resources.c
===================================================================
--- net-2.6.orig/net/atm/resources.c
+++ net-2.6/net/atm/resources.c
@@ -401,7 +401,7 @@ done:
 	return error;
 }
 
-static __inline__ void *dev_get_idx(loff_t left)
+static inline void *dev_get_idx(loff_t left)
 {
 	struct list_head *p;
 

-- 
