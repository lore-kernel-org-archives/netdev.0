From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: [RFC][PATCH 47/75] net: drivers/net/wireless/orinoco_tmd.c pci_module_init to pci_register_driver conversion
Date: Thu, 17 Aug 2006 13:28:42 +0000
Message-ID: <20060817132842.47.NURIpB4835.3636.michal@euridica.enternet.net.pl>
References: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964907AbWHQN2g@vger.kernel.org>
To: joerg@dorchain.net
Content-Disposition: inline
In-Reply-To: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>  
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>

diff -uprN -X linux-work/Documentation/dontdiff linux-work-clean/drivers/net/wireless/orinoco_tmd.c linux-work2/drivers/net/wireless/orinoco_tmd.c
--- linux-work-clean/drivers/net/wireless/orinoco_tmd.c	2006-08-16 22:41:00.000000000 +0200
+++ linux-work2/drivers/net/wireless/orinoco_tmd.c	2006-08-17 05:20:37.000000000 +0200
@@ -228,7 +228,7 @@ MODULE_LICENSE("Dual MPL/GPL");
 static int __init orinoco_tmd_init(void)
 {
 	printk(KERN_DEBUG "%s\n", version);
-	return pci_module_init(&orinoco_tmd_driver);
+	return pci_register_driver(&orinoco_tmd_driver);
 }
 
 static void __exit orinoco_tmd_exit(void)
