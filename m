From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: [RFC][PATCH 75/75] net: drivers/net/yellowfin.c pci_module_init to pci_register_driver conversion
Date: Thu, 17 Aug 2006 13:29:59 +0000
Message-ID: <20060817132959.75.bZTQwX5601.3636.michal@euridica.enternet.net.pl>
References: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964952AbWHQNeW@vger.kernel.org>
To: becker@scyld.com
Content-Disposition: inline
In-Reply-To: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>  
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>

diff -uprN -X linux-work/Documentation/dontdiff linux-work-clean/drivers/net/yellowfin.c linux-work2/drivers/net/yellowfin.c
--- linux-work-clean/drivers/net/yellowfin.c	2006-08-16 22:41:00.000000000 +0200
+++ linux-work2/drivers/net/yellowfin.c	2006-08-17 05:20:50.000000000 +0200
@@ -1434,7 +1434,7 @@ static int __init yellowfin_init (void)
 #ifdef MODULE
 	printk(version);
 #endif
-	return pci_module_init (&yellowfin_driver);
+	return pci_register_driver(&yellowfin_driver);
 }
 
 
