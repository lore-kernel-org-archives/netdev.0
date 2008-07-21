From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [net-2.6 patch 1/1][SCHED] remove unused variable skb in dev_deactivate_queue
 function
Date: Mon, 21 Jul 2008 18:01:31 +0200
Message-ID: <4884B2DB.2000403@fr.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070201040608020204090104"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.uk.ibm.com ([195.212.29.136]:15486 "EHLO
	mtagate3.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750877AbYGUQBs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 12:01:48 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate3.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m6LG1bne304144
	for <netdev@vger.kernel.org>; Mon, 21 Jul 2008 16:01:37 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m6LG1b9P2126046
	for <netdev@vger.kernel.org>; Mon, 21 Jul 2008 17:01:37 +0100
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m6LG1a8C001638
	for <netdev@vger.kernel.org>; Mon, 21 Jul 2008 17:01:36 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070201040608020204090104
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit



--------------070201040608020204090104
Content-Type: text/plain;
 name="remove-unused-variable.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="remove-unused-variable.patch"

Subject: [SCHED] remove unused variable skb in dev_deactivate_queue function
From: Daniel Lezcano <dlezcano@fr.ibm.com>

Removed unused variable 'skb' in the dev_deactivate_queue function

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 net/sched/sch_generic.c |    3 ---
 1 file changed, 3 deletions(-)

Index: net-2.6/net/sched/sch_generic.c
===================================================================
--- net-2.6.orig/net/sched/sch_generic.c
+++ net-2.6/net/sched/sch_generic.c
@@ -576,7 +576,6 @@ static void dev_deactivate_queue(struct 
 				 void *_qdisc_default)
 {
 	struct Qdisc *qdisc_default = _qdisc_default;
-	struct sk_buff *skb = NULL;
 	struct Qdisc *qdisc;
 
 	qdisc = dev_queue->qdisc;
@@ -588,8 +587,6 @@ static void dev_deactivate_queue(struct 
 
 		spin_unlock_bh(qdisc_lock(qdisc));
 	}
-
-	kfree_skb(skb);
 }
 
 static bool some_qdisc_is_running(struct net_device *dev, int lock)

--------------070201040608020204090104--
