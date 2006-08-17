From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: [RFC][PATCH 34/75] net: drivers/net/ixgb/ixgb_main.c pci_module_init to pci_register_driver conversion
Date: Thu, 17 Aug 2006 13:28:10 +0000
Message-ID: <20060817132810.34.TpXmRF4524.3636.michal@euridica.enternet.net.pl>
References: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from euridica.enternet.net.pl ([62.233.231.82]:63137 "EHLO
	euridica.enternet.net.pl") by vger.kernel.org with ESMTP
	id S964876AbWHQN1n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Aug 2006 09:27:43 -0400
To: linux.nics@intel.com
Content-Disposition: inline
In-Reply-To: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>  
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>

diff -uprN -X linux-work/Documentation/dontdiff linux-work-clean/drivers/net/ixgb/ixgb_main.c linux-work2/drivers/net/ixgb/ixgb_main.c
--- linux-work-clean/drivers/net/ixgb/ixgb_main.c	2006-08-16 22:41:17.000000000 +0200
+++ linux-work2/drivers/net/ixgb/ixgb_main.c	2006-08-17 05:15:16.000000000 +0200
@@ -173,7 +173,7 @@ ixgb_init_module(void)
 
 	printk(KERN_INFO "%s\n", ixgb_copyright);
 
-	return pci_module_init(&ixgb_driver);
+	return pci_register_driver(&ixgb_driver);
 }
 
 module_init(ixgb_init_module);
