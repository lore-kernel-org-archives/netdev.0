From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: [RFC][PATCH 20/75] net: drivers/net/e1000/e1000_main.c pci_module_init to pci_register_driver conversion
Date: Thu, 17 Aug 2006 13:27:37 +0000
Message-ID: <20060817132737.20.RyDdba4146.3636.michal@euridica.enternet.net.pl>
References: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from euridica.enternet.net.pl ([62.233.231.82]:20146 "EHLO
	euridica.enternet.net.pl") by vger.kernel.org with ESMTP
	id S964899AbWHQN2q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Aug 2006 09:28:46 -0400
To: linux.nics@intel.com, e1000-devel@lists.sourceforge.net
Content-Disposition: inline
In-Reply-To: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>  
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>

diff -uprN -X linux-work/Documentation/dontdiff linux-work-clean/drivers/net/e1000/e1000_main.c linux-work2/drivers/net/e1000/e1000_main.c
--- linux-work-clean/drivers/net/e1000/e1000_main.c	2006-08-16 22:41:17.000000000 +0200
+++ linux-work2/drivers/net/e1000/e1000_main.c	2006-08-17 05:14:36.000000000 +0200
@@ -245,7 +245,7 @@ e1000_init_module(void)
 
 	printk(KERN_INFO "%s\n", e1000_copyright);
 
-	ret = pci_module_init(&e1000_driver);
+	ret = pci_register_driver(&e1000_driver);
 
 	return ret;
 }
