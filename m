From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: [RFC][PATCH 3/75] net: drivers/net/8139cp.c pci_module_init to pci_register_driver conversion
Date: Thu, 17 Aug 2006 13:26:46 +0000
Message-ID: <20060817132646.3.TfgBLE3713.3636.michal@euridica.enternet.net.pl>
References: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from euridica.enternet.net.pl ([62.233.231.82]:41650 "EHLO
	euridica.enternet.net.pl") by vger.kernel.org with ESMTP
	id S964946AbWHQN3j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Aug 2006 09:29:39 -0400
To: jgarzik@pobox.com
Content-Disposition: inline
In-Reply-To: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>  
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>

diff -uprN -X linux-work/Documentation/dontdiff linux-work-clean/drivers/net/8139cp.c linux-work2/drivers/net/8139cp.c
--- linux-work-clean/drivers/net/8139cp.c	2006-08-16 22:41:16.000000000 +0200
+++ linux-work2/drivers/net/8139cp.c	2006-08-17 05:13:25.000000000 +0200
@@ -2098,7 +2098,7 @@ static int __init cp_init (void)
 #ifdef MODULE
 	printk("%s", version);
 #endif
-	return pci_module_init (&cp_driver);
+	return pci_register_driver(&cp_driver);
 }
 
 static void __exit cp_exit (void)
