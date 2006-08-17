From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: [RFC][PATCH 2/75] net: drivers/net/3c59x.c pci_module_init to pci_register_driver conversion
Date: Thu, 17 Aug 2006 13:26:42 +0000
Message-ID: <20060817132642.2.nLUCxk3688.3636.michal@euridica.enternet.net.pl>
References: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964867AbWHQN70@vger.kernel.org>
To: becker@scyld.com
Content-Disposition: inline
In-Reply-To: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>  
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>

diff -uprN -X linux-work/Documentation/dontdiff linux-work-clean/drivers/net/3c59x.c linux-work2/drivers/net/3c59x.c
--- linux-work-clean/drivers/net/3c59x.c	2006-08-16 22:41:16.000000000 +0200
+++ linux-work2/drivers/net/3c59x.c	2006-08-17 05:13:16.000000000 +0200
@@ -3170,7 +3170,7 @@ static int __init vortex_init(void)
 {
 	int pci_rc, eisa_rc;
 
-	pci_rc = pci_module_init(&vortex_driver);
+	pci_rc = pci_register_driver(&vortex_driver);
 	eisa_rc = vortex_eisa_init();
 
 	if (pci_rc == 0)
