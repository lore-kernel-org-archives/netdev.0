From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 09/14] replace __inline__ by inline in net/llc
Date: Wed, 06 Feb 2008 10:14:14 +0100
Message-ID: <20080206092147.567706689@mai.toulouse-stg.fr.ibm.com>
References: <20080206091405.581849582@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.29.153]:62900 "EHLO
	mtagate4.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759036AbYBFJ1X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2008 04:27:23 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate4.de.ibm.com (8.13.8/8.13.8) with ESMTP id m169RI92157378
	for <netdev@vger.kernel.org>; Wed, 6 Feb 2008 09:27:18 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m169RIYK1966136
	for <netdev@vger.kernel.org>; Wed, 6 Feb 2008 10:27:18 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m169RIgF001968
	for <netdev@vger.kernel.org>; Wed, 6 Feb 2008 10:27:18 +0100
Content-Disposition: inline; filename=remove-__inline__-in-llc.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

replace __inline__ by inline in net/llc

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 net/llc/llc_input.c   |    2 +-
 net/llc/llc_station.c |    3 +--
 2 files changed, 2 insertions(+), 3 deletions(-)

Index: net-2.6/net/llc/llc_input.c
===================================================================
--- net-2.6.orig/net/llc/llc_input.c
+++ net-2.6/net/llc/llc_input.c
@@ -61,7 +61,7 @@ void llc_set_station_handler(void (*hand
  *
  *	This function returns which LLC component must handle this PDU.
  */
-static __inline__ int llc_pdu_type(struct sk_buff *skb)
+static inline int llc_pdu_type(struct sk_buff *skb)
 {
 	int type = LLC_DEST_CONN; /* I-PDU or S-PDU type */
 	struct llc_pdu_sn *pdu = llc_pdu_sn_hdr(skb);
Index: net-2.6/net/llc/llc_station.c
===================================================================
--- net-2.6.orig/net/llc/llc_station.c
+++ net-2.6/net/llc/llc_station.c
@@ -80,8 +80,7 @@ struct llc_station_state_ev {
 	struct list_head node; /* node in station->ev_q.list */
 };
 
-static __inline__ struct llc_station_state_ev *
-					llc_station_ev(struct sk_buff *skb)
+static inline struct llc_station_state_ev *llc_station_ev(struct sk_buff *skb)
 {
 	return (struct llc_station_state_ev *)skb->cb;
 }

-- 
