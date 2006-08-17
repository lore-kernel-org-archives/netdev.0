From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: [RFC][PATCH 68/75] net: drivers/net/tulip/tulip_core.c pci_module_init to pci_register_driver conversion
Date: Thu, 17 Aug 2006 13:29:45 +0000
Message-ID: <20060817132945.68.cHhBof5402.3636.michal@euridica.enternet.net.pl>
References: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from euridica.enternet.net.pl ([62.233.231.82]:145 "EHLO
	euridica.enternet.net.pl") by vger.kernel.org with ESMTP
	id S964973AbWHQNgs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Aug 2006 09:36:48 -0400
To: jgarzik@pobox.com
Content-Disposition: inline
In-Reply-To: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>  
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>

diff -uprN -X linux-work/Documentation/dontdiff linux-work-clean/drivers/net/tulip/tulip_core.c linux-work2/drivers/net/tulip/tulip_core.c
--- linux-work-clean/drivers/net/tulip/tulip_core.c	2006-08-16 22:41:17.000000000 +0200
+++ linux-work2/drivers/net/tulip/tulip_core.c	2006-08-17 05:18:56.000000000 +0200
@@ -1860,7 +1860,7 @@ static int __init tulip_init (void)
 	tulip_max_interrupt_work = max_interrupt_work;
 
 	/* probe for and init boards */
-	return pci_module_init (&tulip_driver);
+	return pci_register_driver(&tulip_driver);
 }
 
 
