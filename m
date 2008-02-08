From: Ursula Braun <braunu@de.ibm.com>
Subject: [patch 2/5] netiucv: Remember to set driver->owner.
Date: Fri, 08 Feb 2008 13:09:02 +0100
Message-ID: <20080208121513.163459000@linux.vnet.ibm.com>
References: <20080208120900.295604000@linux.vnet.ibm.com>
Cc: Cornelia Huck <cornelia.huck@de.ibm.com>
To: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.29.152]:40354 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759548AbYBHMPQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2008 07:15:16 -0500
Content-Disposition: inline; filename=752-netiucv-owner.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cornelia Huck <cornelia.huck@de.ibm.com>

Signed-off-by: Cornelia Huck <cornelia.huck@de.ibm.com>
Signed-off-by: Ursula Braun <braunu@de.ibm.com>
---

 drivers/s390/net/netiucv.c |    1 +
 1 file changed, 1 insertion(+)

Index: linux-2.6-uschi/drivers/s390/net/netiucv.c
===================================================================
--- linux-2.6-uschi.orig/drivers/s390/net/netiucv.c
+++ linux-2.6-uschi/drivers/s390/net/netiucv.c
@@ -137,6 +137,7 @@ PRINT_##importance(header "%02x %02x %02
 #define PRINTK_HEADER " iucv: "       /* for debugging */
 
 static struct device_driver netiucv_driver = {
+	.owner = THIS_MODULE,
 	.name = "netiucv",
 	.bus  = &iucv_bus,
 };

-- 
