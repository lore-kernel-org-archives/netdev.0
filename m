From: akpm@linux-foundation.org
Subject: [patch for 2.6.25? 3/3] sc92031: sysfs link missing
Date: Thu, 10 Apr 2008 21:30:38 -0700
Message-ID: <200804110430.m3B4UcVU000439@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	shemminger@vyatta.com, cesarb@cesarb.net, jgarzik@pobox.com,
	tom@sharkbay.at
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:59635 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750957AbYDKEbQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2008 00:31:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>

Add missing sysfs device association. Compile tested only -ENOHW.

Addresses http://bugzilla.kernel.org/show_bug.cgi?id=10380

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Cc: Jeff Garzik <jgarzik@pobox.com>
Cc: Cesar Eduardo Barros <cesarb@cesarb.net>
Cc: <tom@sharkbay.at>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/sc92031.c |    1 +
 1 file changed, 1 insertion(+)

diff -puN drivers/net/sc92031.c~sc92031-sysfs-link-missing drivers/net/sc92031.c
--- a/drivers/net/sc92031.c~sc92031-sysfs-link-missing
+++ a/drivers/net/sc92031.c
@@ -1444,6 +1444,7 @@ static int __devinit sc92031_probe(struc
 	}
 
 	pci_set_drvdata(pdev, dev);
+	SET_NETDEV_DEV(dev, &pdev->dev);
 
 #if SC92031_USE_BAR == 0
 	dev->mem_start = pci_resource_start(pdev, SC92031_USE_BAR);
_
