From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: [RFC][PATCH 37/75] net: drivers/net/wan/lmc/lmc_main.c pci_module_init to pci_register_driver conversion
Date: Thu, 17 Aug 2006 13:28:16 +0000
Message-ID: <20060817132816.37.yxjmeA4594.3636.michal@euridica.enternet.net.pl>
References: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from euridica.enternet.net.pl ([62.233.231.82]:64417 "EHLO
	euridica.enternet.net.pl") by vger.kernel.org with ESMTP
	id S964859AbWHQN1s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Aug 2006 09:27:48 -0400
To: asj@cban.com
Content-Disposition: inline
In-Reply-To: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>  
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>

diff -uprN -X linux-work/Documentation/dontdiff linux-work-clean/drivers/net/wan/lmc/lmc_main.c linux-work2/drivers/net/wan/lmc/lmc_main.c
--- linux-work-clean/drivers/net/wan/lmc/lmc_main.c	2006-08-16 22:41:00.000000000 +0200
+++ linux-work2/drivers/net/wan/lmc/lmc_main.c	2006-08-17 05:19:43.000000000 +0200
@@ -1790,7 +1790,7 @@ static struct pci_driver lmc_driver = {
 
 static int __init init_lmc(void)
 {
-    return pci_module_init(&lmc_driver);
+    return pci_register_driver(&lmc_driver);
 }
 
 static void __exit exit_lmc(void)
