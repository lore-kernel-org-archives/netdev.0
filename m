From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: [RFC][PATCH 32/75] net: drivers/net/wireless/ipw2200.c pci_module_init to pci_register_driver conversion
Date: Thu, 17 Aug 2006 13:28:06 +0000
Message-ID: <20060817132806.32.NwBxBR4470.3636.michal@euridica.enternet.net.pl>
References: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964996AbWHQNn7@vger.kernel.org>
To: ipw2100-admin@linux.intel.com
Content-Disposition: inline
In-Reply-To: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>  
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>

diff -uprN -X linux-work/Documentation/dontdiff linux-work-clean/drivers/net/wireless/ipw2200.c linux-work2/drivers/net/wireless/ipw2200.c
--- linux-work-clean/drivers/net/wireless/ipw2200.c	2006-08-16 22:41:17.000000000 +0200
+++ linux-work2/drivers/net/wireless/ipw2200.c	2006-08-17 05:20:17.000000000 +0200
@@ -11753,7 +11753,7 @@ static int __init ipw_init(void)
 	printk(KERN_INFO DRV_NAME ": " DRV_DESCRIPTION ", " DRV_VERSION "\n");
 	printk(KERN_INFO DRV_NAME ": " DRV_COPYRIGHT "\n");
 
-	ret = pci_module_init(&ipw_driver);
+	ret = pci_register_driver(&ipw_driver);
 	if (ret) {
 		IPW_ERROR("Unable to initialize PCI module\n");
 		return ret;
