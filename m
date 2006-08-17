From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: [RFC][PATCH 74/75] net: drivers/net/tulip/xircom_tulip_cb.c pci_module_init to pci_register_driver conversion
Date: Thu, 17 Aug 2006 13:29:57 +0000
Message-ID: <20060817132957.74.gOFNrr5566.3636.michal@euridica.enternet.net.pl>
References: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from euridica.enternet.net.pl ([62.233.231.82]:37554 "EHLO
	euridica.enternet.net.pl") by vger.kernel.org with ESMTP
	id S964942AbWHQN3X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Aug 2006 09:29:23 -0400
To: becker@scyld.com
Content-Disposition: inline
In-Reply-To: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>  
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>

diff -uprN -X linux-work/Documentation/dontdiff linux-work-clean/drivers/net/tulip/xircom_tulip_cb.c linux-work2/drivers/net/tulip/xircom_tulip_cb.c
--- linux-work-clean/drivers/net/tulip/xircom_tulip_cb.c	2006-08-16 22:41:00.000000000 +0200
+++ linux-work2/drivers/net/tulip/xircom_tulip_cb.c	2006-08-17 05:19:07.000000000 +0200
@@ -1707,7 +1707,7 @@ static int __init xircom_init(void)
 #ifdef MODULE
 	printk(version);
 #endif
-	return pci_module_init(&xircom_driver);
+	return pci_register_driver(&xircom_driver);
 }
 
 
