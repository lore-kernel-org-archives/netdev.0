From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: [RFC][PATCH 13/75] net: drivers/net/chelsio/cxgb2.c pci_module_init to pci_register_driver conversion
Date: Thu, 17 Aug 2006 13:27:10 +0000
Message-ID: <20060817132710.13.yZCPrn3983.3636.michal@euridica.enternet.net.pl>
References: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from euridica.enternet.net.pl ([62.233.231.82]:41121 "EHLO
	euridica.enternet.net.pl") by vger.kernel.org with ESMTP
	id S932513AbWHQN0r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Aug 2006 09:26:47 -0400
To: maintainers@chelsio.com
Content-Disposition: inline
In-Reply-To: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>  
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>

diff -uprN -X linux-work/Documentation/dontdiff linux-work-clean/drivers/net/chelsio/cxgb2.c linux-work2/drivers/net/chelsio/cxgb2.c
--- linux-work-clean/drivers/net/chelsio/cxgb2.c	2006-08-16 22:40:59.000000000 +0200
+++ linux-work2/drivers/net/chelsio/cxgb2.c	2006-08-17 05:14:12.000000000 +0200
@@ -1243,7 +1243,7 @@ static struct pci_driver driver = {
 
 static int __init t1_init_module(void)
 {
-	return pci_module_init(&driver);
+	return pci_register_driver(&driver);
 }
 
 static void __exit t1_cleanup_module(void)
