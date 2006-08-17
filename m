From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: [RFC][PATCH 14/75] net: drivers/net/tulip/de2104x.c pci_module_init to pci_register_driver conversion
Date: Thu, 17 Aug 2006 13:27:19 +0000
Message-ID: <20060817132719.14.HYHEKd4004.3636.michal@euridica.enternet.net.pl>
References: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964921AbWHQNi3@vger.kernel.org>
To: jgarzik@pobox.com
Content-Disposition: inline
In-Reply-To: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>  
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>

diff -uprN -X linux-work/Documentation/dontdiff linux-work-clean/drivers/net/tulip/de2104x.c linux-work2/drivers/net/tulip/de2104x.c
--- linux-work-clean/drivers/net/tulip/de2104x.c	2006-08-16 22:41:00.000000000 +0200
+++ linux-work2/drivers/net/tulip/de2104x.c	2006-08-17 05:18:32.000000000 +0200
@@ -2172,7 +2172,7 @@ static int __init de_init (void)
 #ifdef MODULE
 	printk("%s", version);
 #endif
-	return pci_module_init (&de_driver);
+	return pci_register_driver(&de_driver);
 }
 
 static void __exit de_exit (void)
