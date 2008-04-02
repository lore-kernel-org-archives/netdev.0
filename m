From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] sc92031: sysfs link missing
Date: Wed, 2 Apr 2008 09:39:56 -0700
Message-ID: <20080402093956.2520ebfd@extreme>
References: <bug-10380-10286@http.bugzilla.kernel.org/>
	<20080402091435.39f99428.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	Cesar Eduardo Barros <cesarb@cesarb.net>, tom@sharkbay.at
To: Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:59081 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759361AbYDBQkD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Apr 2008 12:40:03 -0400
In-Reply-To: <20080402091435.39f99428.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add missing sysfs device association. Compile tested only -ENOHW.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/sc92031.c	2008-04-02 09:34:35.000000000 -0700
+++ b/drivers/net/sc92031.c	2008-04-02 09:36:53.000000000 -0700
@@ -1446,6 +1446,7 @@ static int __devinit sc92031_probe(struc
 	}
 
 	pci_set_drvdata(pdev, dev);
+	SET_NETDEV_DEV(dev, &hw->pdev->dev);
 
 #if SC92031_USE_BAR == 0
 	dev->mem_start = pci_resource_start(pdev, SC92031_USE_BAR);
