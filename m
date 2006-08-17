From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: [RFC][PATCH 15/75] net: drivers/net/tulip/de4x5.c pci_module_init to pci_register_driver conversion
Date: Thu, 17 Aug 2006 13:27:21 +0000
Message-ID: <20060817132721.15.YjEJVk4029.3636.michal@euridica.enternet.net.pl>
References: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964840AbWHQN65@vger.kernel.org>
To: netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>  
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>

diff -uprN -X linux-work/Documentation/dontdiff linux-work-clean/drivers/net/tulip/de4x5.c linux-work2/drivers/net/tulip/de4x5.c
--- linux-work-clean/drivers/net/tulip/de4x5.c	2006-08-16 22:41:17.000000000 +0200
+++ linux-work2/drivers/net/tulip/de4x5.c	2006-08-17 05:18:44.000000000 +0200
@@ -5755,7 +5755,7 @@ static int __init de4x5_module_init (voi
 	int err = 0;
 
 #ifdef CONFIG_PCI
-	err = pci_module_init (&de4x5_pci_driver);
+	err = pci_register_driver(&de4x5_pci_driver);
 #endif
 #ifdef CONFIG_EISA
 	err |= eisa_driver_register (&de4x5_eisa_driver);
