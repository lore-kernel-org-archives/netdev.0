From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: [RFC][PATCH 49/75] net: drivers/net/wan/pc300_drv.c pci_module_init to pci_register_driver conversion
Date: Thu, 17 Aug 2006 13:28:52 +0000
Message-ID: <20060817132852.49.EjbOTA4899.3636.michal@euridica.enternet.net.pl>
References: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from euridica.enternet.net.pl ([62.233.231.82]:15010 "EHLO
	euridica.enternet.net.pl") by vger.kernel.org with ESMTP
	id S964899AbWHQN23 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Aug 2006 09:28:29 -0400
To: pc300@cyclades.com
Content-Disposition: inline
In-Reply-To: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>  
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>

diff -uprN -X linux-work/Documentation/dontdiff linux-work-clean/drivers/net/wan/pc300_drv.c linux-work2/drivers/net/wan/pc300_drv.c
--- linux-work-clean/drivers/net/wan/pc300_drv.c	2006-08-16 22:41:00.000000000 +0200
+++ linux-work2/drivers/net/wan/pc300_drv.c	2006-08-17 05:19:51.000000000 +0200
@@ -3677,7 +3677,7 @@ static struct pci_driver cpc_driver = {
 
 static int __init cpc_init(void)
 {
-	return pci_module_init(&cpc_driver);
+	return pci_register_driver(&cpc_driver);
 }
 
 static void __exit cpc_cleanup_module(void)
