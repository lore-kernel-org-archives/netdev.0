From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH] net: convert one non-symbolic return value in dev_queue_xmit
Date: Sun, 30 Aug 2009 11:51:36 +0530
Message-ID: <20090830062136.6299.31696.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Krishna Kumar <krkumar2@in.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp08.au.ibm.com ([202.81.31.141]:60657 "EHLO
	e23smtp08.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751405AbZH3GVe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Aug 2009 02:21:34 -0400
Received: from d23relay01.au.ibm.com (d23relay01.au.ibm.com [202.81.31.243])
	by e23smtp08.au.ibm.com (8.14.3/8.13.1) with ESMTP id n7U6JttB001720
	for <netdev@vger.kernel.org>; Sun, 30 Aug 2009 16:19:55 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay01.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7U6LaiH397780
	for <netdev@vger.kernel.org>; Sun, 30 Aug 2009 16:21:36 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n7U6LaPl032230
	for <netdev@vger.kernel.org>; Sun, 30 Aug 2009 16:21:36 +1000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar <krkumar2@in.ibm.com>

net: convert remaining non-symbolic return values in dev_queue_xmit

Patch compiled and 32 simultaneous netperf testing ran fine. 

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---

 net/core/dev.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)
diff -ruNp org/net/core/dev.c new/net/core/dev.c
--- org/net/core/dev.c	2009-08-28 21:36:46.000000000 +0530
+++ new/net/core/dev.c	2009-08-28 21:40:36.000000000 +0530
@@ -1917,7 +1917,7 @@ gso:
 			HARD_TX_LOCK(dev, txq, cpu);
 
 			if (!netif_tx_queue_stopped(txq)) {
-				rc = 0;
+				rc = NET_XMIT_SUCCESS;
 				if (!dev_hard_start_xmit(skb, dev, txq)) {
 					HARD_TX_UNLOCK(dev, txq);
 					goto out;
