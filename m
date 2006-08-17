From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: [RFC][PATCH 26/75] net: drivers/net/forcedeth.c pci_module_init to pci_register_driver conversion
Date: Thu, 17 Aug 2006 13:27:52 +0000
Message-ID: <20060817132752.26.EHLcWf4305.3636.michal@euridica.enternet.net.pl>
References: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964870AbWHQNxV@vger.kernel.org>
To: netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>  
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>

diff -uprN -X linux-work/Documentation/dontdiff linux-work-clean/drivers/net/forcedeth.c linux-work2/drivers/net/forcedeth.c
--- linux-work-clean/drivers/net/forcedeth.c	2006-08-16 22:41:17.000000000 +0200
+++ linux-work2/drivers/net/forcedeth.c	2006-08-17 05:15:01.000000000 +0200
@@ -4668,7 +4668,7 @@ static struct pci_driver driver = {
 static int __init init_nic(void)
 {
 	printk(KERN_INFO "forcedeth.c: Reverse Engineered nForce ethernet driver. Version %s.\n", FORCEDETH_VERSION);
-	return pci_module_init(&driver);
+	return pci_register_driver(&driver);
 }
 
 static void __exit exit_nic(void)
