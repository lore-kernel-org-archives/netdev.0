From: Frank Pavlic <fpavlic@de.ibm.com>
Subject: [PATCH 7/8] s390: netiucv spinlock initializer cleanup
Date: Wed, 20 Jun 2007 13:02:55 +0200
Message-ID: <20070620110255.GG9454@de.ibm.com>
References: <20070620104817.GA2627@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:47221 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750957AbXFTLDo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jun 2007 07:03:44 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5KB3icC004256
	for <netdev@vger.kernel.org>; Wed, 20 Jun 2007 07:03:44 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5KB3itg484738
	for <netdev@vger.kernel.org>; Wed, 20 Jun 2007 07:03:44 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5KB3h1e005033
	for <netdev@vger.kernel.org>; Wed, 20 Jun 2007 07:03:43 -0400
Content-Disposition: inline
In-Reply-To: <20070620104817.GA2627@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Gleixner <tglx@linutronix.de>

spinlock initializer cleanup in netiucv.c

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Frank Pavlic <fpavlic@de.ibm.com>
---
 drivers/s390/net/netiucv.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/s390/net/netiucv.c b/drivers/s390/net/netiucv.c
index 648ee13..5303aea 100644
--- a/drivers/s390/net/netiucv.c
+++ b/drivers/s390/net/netiucv.c
@@ -212,7 +212,7 @@ struct iucv_connection {
  */
 static struct list_head iucv_connection_list =
 	LIST_HEAD_INIT(iucv_connection_list);
-static rwlock_t iucv_connection_rwlock = RW_LOCK_UNLOCKED;
+static DEFINE_RWLOCK(iucv_connection_rwlock);
 
 /**
  * Representation of event-data for the
-- 
1.5.2.1

