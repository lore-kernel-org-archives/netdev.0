From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: [RFC][PATCH 19/75] net: drivers/net/wan/dscc4.c pci_module_init to pci_register_driver conversion
Date: Thu, 17 Aug 2006 13:27:30 +0000
Message-ID: <20060817132730.19.syFWXZ4113.3636.michal@euridica.enternet.net.pl>
References: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965006AbWHQN4A@vger.kernel.org>
To: romieu@cogenit.fr
Content-Disposition: inline
In-Reply-To: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>  
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>

diff -uprN -X linux-work/Documentation/dontdiff linux-work-clean/drivers/net/wan/dscc4.c linux-work2/drivers/net/wan/dscc4.c
--- linux-work-clean/drivers/net/wan/dscc4.c	2006-08-16 22:41:00.000000000 +0200
+++ linux-work2/drivers/net/wan/dscc4.c	2006-08-17 05:19:30.000000000 +0200
@@ -2062,7 +2062,7 @@ static struct pci_driver dscc4_driver = 
 
 static int __init dscc4_init_module(void)
 {
-	return pci_module_init(&dscc4_driver);
+	return pci_register_driver(&dscc4_driver);
 }
 
 static void __exit dscc4_cleanup_module(void)
