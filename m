From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: [RFC][PATCH 21/75] net: drivers/net/e100.c pci_module_init to pci_register_driver conversion
Date: Thu, 17 Aug 2006 13:27:39 +0000
Message-ID: <20060817132739.21.RicHDU4163.3636.michal@euridica.enternet.net.pl>
References: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from euridica.enternet.net.pl ([62.233.231.82]:47777 "EHLO
	euridica.enternet.net.pl") by vger.kernel.org with ESMTP
	id S964853AbWHQN1G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Aug 2006 09:27:06 -0400
To: scott.feldman@intel.com
Content-Disposition: inline
In-Reply-To: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>  
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>

diff -uprN -X linux-work/Documentation/dontdiff linux-work-clean/drivers/net/e100.c linux-work2/drivers/net/e100.c
--- linux-work-clean/drivers/net/e100.c	2006-08-16 22:41:17.000000000 +0200
+++ linux-work2/drivers/net/e100.c	2006-08-17 05:14:31.000000000 +0200
@@ -2820,7 +2820,7 @@ static int __init e100_init_module(void)
 		printk(KERN_INFO PFX "%s, %s\n", DRV_DESCRIPTION, DRV_VERSION);
 		printk(KERN_INFO PFX "%s\n", DRV_COPYRIGHT);
 	}
-	return pci_module_init(&e100_driver);
+	return pci_register_driver(&e100_driver);
 }
 
 static void __exit e100_cleanup_module(void)
