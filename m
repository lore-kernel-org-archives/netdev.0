From: Ursula Braun <braunu@de.ibm.com>
Subject: [patch 1/5] claw: removal of volatile variables
Date: Fri, 08 Feb 2008 13:09:01 +0100
Message-ID: <20080208121512.532071000@linux.vnet.ibm.com>
References: <20080208120900.295604000@linux.vnet.ibm.com>
To: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.de.ibm.com ([195.212.29.157]:30812 "EHLO
	mtagate8.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759235AbYBHMPP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2008 07:15:15 -0500
Content-Disposition: inline; filename=719-claw-volatile.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <braunu@de.ibm.com>

Volatile variables queme_switch and pk_delay are not used anyway.
They are just a left over from an unused timer based packing logic.

Signed-off-by: Ursula Braun <braunu@de.ibm.com>
---

 drivers/s390/net/claw.h |    2 --
 1 file changed, 2 deletions(-)

Index: linux-2.6-uschi/drivers/s390/net/claw.h
===================================================================
--- linux-2.6-uschi.orig/drivers/s390/net/claw.h
+++ linux-2.6-uschi/drivers/s390/net/claw.h
@@ -278,8 +278,6 @@ struct claw_env {
         __u16                   write_size;     /* write buffer size */
         __u16                   dev_id;         /* device ident */
 	__u8			packing;	/* are we packing? */
-	volatile __u8		queme_switch;   /* gate for imed packing  */
-	volatile unsigned long	pk_delay;	/* Delay for adaptive packing */
         __u8                    in_use;         /* device active flag */
         struct net_device       *ndev;    	/* backward ptr to the net dev*/
 };

-- 
