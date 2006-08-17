From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: [RFC][PATCH 72/75] net: drivers/net/wan/wanxl.c pci_module_init to pci_register_driver conversion
Date: Thu, 17 Aug 2006 13:29:53 +0000
Message-ID: <20060817132953.72.KFiEzs5518.3636.michal@euridica.enternet.net.pl>
References: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964926AbWHQNgv@vger.kernel.org>
To: khc@pm.waw.pl
Content-Disposition: inline
In-Reply-To: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>  
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>

diff -uprN -X linux-work/Documentation/dontdiff linux-work-clean/drivers/net/wan/wanxl.c linux-work2/drivers/net/wan/wanxl.c
--- linux-work-clean/drivers/net/wan/wanxl.c	2006-08-16 22:41:00.000000000 +0200
+++ linux-work2/drivers/net/wan/wanxl.c	2006-08-17 05:20:02.000000000 +0200
@@ -837,7 +837,7 @@ static int __init wanxl_init_module(void
 #ifdef MODULE
 	printk(KERN_INFO "%s\n", version);
 #endif
-	return pci_module_init(&wanxl_pci_driver);
+	return pci_register_driver(&wanxl_pci_driver);
 }
 
 static void __exit wanxl_cleanup_module(void)
