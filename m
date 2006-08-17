From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: [RFC][PATCH 61/75] net: drivers/net/skge.c pci_module_init to pci_register_driver conversion
Date: Thu, 17 Aug 2006 13:29:28 +0000
Message-ID: <20060817132928.61.yPYKdp5226.3636.michal@euridica.enternet.net.pl>
References: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from euridica.enternet.net.pl ([62.233.231.82]:27058 "EHLO
	euridica.enternet.net.pl") by vger.kernel.org with ESMTP
	id S964925AbWHQN3B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Aug 2006 09:29:01 -0400
To: shemminger@osdl.org
Content-Disposition: inline
In-Reply-To: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>  
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>

diff -uprN -X linux-work/Documentation/dontdiff linux-work-clean/drivers/net/skge.c linux-work2/drivers/net/skge.c
--- linux-work-clean/drivers/net/skge.c	2006-08-16 22:41:17.000000000 +0200
+++ linux-work2/drivers/net/skge.c	2006-08-17 05:17:04.000000000 +0200
@@ -3510,7 +3510,7 @@ static struct pci_driver skge_driver = {
 
 static int __init skge_init_module(void)
 {
-	return pci_module_init(&skge_driver);
+	return pci_register_driver(&skge_driver);
 }
 
 static void __exit skge_cleanup_module(void)
