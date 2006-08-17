From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: [RFC][PATCH 51/75] net: drivers/net/pci-skeleton.c pci_module_init to pci_register_driver conversion
Date: Thu, 17 Aug 2006 13:28:58 +0000
Message-ID: <20060817132858.51.mFaGck4945.3636.michal@euridica.enternet.net.pl>
References: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from euridica.enternet.net.pl ([62.233.231.82]:39858 "EHLO
	euridica.enternet.net.pl") by vger.kernel.org with ESMTP
	id S964944AbWHQN3b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Aug 2006 09:29:31 -0400
To: jgarzik@pobox.com
Content-Disposition: inline
In-Reply-To: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>  
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>

diff -uprN -X linux-work/Documentation/dontdiff linux-work-clean/drivers/net/pci-skeleton.c linux-work2/drivers/net/pci-skeleton.c
--- linux-work-clean/drivers/net/pci-skeleton.c	2006-08-16 22:41:00.000000000 +0200
+++ linux-work2/drivers/net/pci-skeleton.c	2006-08-17 05:15:43.000000000 +0200
@@ -1963,7 +1963,7 @@ static int __init netdrv_init_module (vo
 #ifdef MODULE
 	printk(version);
 #endif
-	return pci_module_init (&netdrv_pci_driver);
+	return pci_register_driver(&netdrv_pci_driver);
 }
 
 
