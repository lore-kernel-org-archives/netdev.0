From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: [RFC][PATCH 42/75] net: drivers/net/ns83820.c pci_module_init to pci_register_driver conversion
Date: Thu, 17 Aug 2006 13:28:30 +0000
Message-ID: <20060817132830.42.VTaHzL4694.3636.michal@euridica.enternet.net.pl>
References: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from euridica.enternet.net.pl ([62.233.231.82]:6562 "EHLO
	euridica.enternet.net.pl") by vger.kernel.org with ESMTP
	id S964884AbWHQN2B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Aug 2006 09:28:01 -0400
To: linux-ns83820@kvack.org
Content-Disposition: inline
In-Reply-To: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>  
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>

diff -uprN -X linux-work/Documentation/dontdiff linux-work-clean/drivers/net/ns83820.c linux-work2/drivers/net/ns83820.c
--- linux-work-clean/drivers/net/ns83820.c	2006-08-16 22:41:17.000000000 +0200
+++ linux-work2/drivers/net/ns83820.c	2006-08-17 05:15:34.000000000 +0200
@@ -2336,7 +2336,7 @@ static struct pci_driver driver = {
 static int __init ns83820_init(void)
 {
 	printk(KERN_INFO "ns83820.c: National Semiconductor DP83820 10/100/1000 driver.\n");
-	return pci_module_init(&driver);
+	return pci_register_driver(&driver);
 }
 
 static void __exit ns83820_exit(void)
