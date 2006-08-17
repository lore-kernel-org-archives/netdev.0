From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: [RFC][PATCH 59/75] net: net/skfp/skfddi.c pci_module_init to pci_register_driver conversion
Date: Thu, 17 Aug 2006 13:29:23 +0000
Message-ID: <20060817132923.59.cJVopb5162.3636.michal@euridica.enternet.net.pl>
References: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964976AbWHQNky@vger.kernel.org>
To: cgoos@syskonnect.de
Content-Disposition: inline
In-Reply-To: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>  
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>

diff -uprN -X linux-work/Documentation/dontdiff linux-work-clean/drivers/net/skfp/skfddi.c linux-work2/drivers/net/skfp/skfddi.c
--- linux-work-clean/drivers/net/skfp/skfddi.c	2006-08-16 22:41:00.000000000 +0200
+++ linux-work2/drivers/net/skfp/skfddi.c	2006-08-17 05:16:45.000000000 +0200
@@ -2280,7 +2280,7 @@ static struct pci_driver skfddi_pci_driv
 
 static int __init skfd_init(void)
 {
-	return pci_module_init(&skfddi_pci_driver);
+	return pci_register_driver(&skfddi_pci_driver);
 }
 
 static void __exit skfd_exit(void)
