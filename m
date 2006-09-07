From: "Darren Jenkins\\" <darrenrjenkins@gmail.com>
Subject: [KJ][Patch] remove dead code in bcm43xx_sysfs.c
Date: Thu, 07 Sep 2006 17:27:39 +1000
Message-ID: <1157614059.22555.19.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: mb@bu3sch.de, NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.176]:45 "EHLO
	py-out-1112.google.com") by vger.kernel.org with ESMTP
	id S1750745AbWIGH2L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Sep 2006 03:28:11 -0400
Received: by py-out-1112.google.com with SMTP id x66so187026pye
        for <netdev@vger.kernel.org>; Thu, 07 Sep 2006 00:28:10 -0700 (PDT)
To: kernel Janitors <kernel-janitors@lists.osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

G'day people,

Coverity CID 1161

This is probably fixed in some external tree, but in case it isn't, here is a patch


Compile tested with allyesconfig


Remove some dead code from bcm43xx_sysfs.c in 2.6.18-rc6

Signed-off-by: Darren Jenkins <darrenrjenkins@gmail.com>
--- drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c.orig	2006-09-07 15:40:33.000000000 +1000
+++ drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c	2006-09-07 15:42:02.000000000 +1000
@@ -276,7 +276,6 @@ static ssize_t bcm43xx_attr_preamble_sto
 {
 	struct bcm43xx_private *bcm = dev_to_bcm(dev);
 	unsigned long flags;
-	int err;
 	int value;
 
 	if (!capable(CAP_NET_ADMIN))
@@ -289,10 +288,9 @@ static ssize_t bcm43xx_attr_preamble_sto
 
 	bcm->short_preamble = !!value;
 
-	err = 0;
 	bcm43xx_unlock_irqsafe(bcm, flags);
 
-	return err ? err : count;
+	return count;
 }
 
 static DEVICE_ATTR(shortpreamble, 0644,


