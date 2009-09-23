From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/2] pktgen: T_TERMINATE flag is unused
Date: Tue, 22 Sep 2009 22:41:42 -0700
Message-ID: <20090923054201.440781719@vyatta.com>
References: <20090923054141.932043798@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:56728 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752032AbZIWFno (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Sep 2009 01:43:44 -0400
Content-Disposition: inline; filename=pktgen-terminate.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Get rid of unused flag bit.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/core/pktgen.c	2009-09-21 20:35:50.106198752 -0700
+++ b/net/core/pktgen.c	2009-09-21 20:36:03.349310985 -0700
@@ -192,11 +192,10 @@
 #define F_QUEUE_MAP_CPU (1<<14)	/* queue map mirrors smp_processor_id() */
 
 /* Thread control flag bits */
-#define T_TERMINATE   (1<<0)
-#define T_STOP        (1<<1)	/* Stop run */
-#define T_RUN         (1<<2)	/* Start run */
-#define T_REMDEVALL   (1<<3)	/* Remove all devs */
-#define T_REMDEV      (1<<4)	/* Remove one dev */
+#define T_STOP        (1<<0)	/* Stop run */
+#define T_RUN         (1<<1)	/* Start run */
+#define T_REMDEVALL   (1<<2)	/* Remove all devs */
+#define T_REMDEV      (1<<3)	/* Remove one dev */
 
 /* If lock -- can be removed after some work */
 #define   if_lock(t)           spin_lock(&(t->if_lock));

-- 

