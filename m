From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: [RFC][PATCH 41/75] net: drivers/net/ne2k-pci.c pci_module_init to pci_register_driver conversion
Date: Thu, 17 Aug 2006 13:28:28 +0000
Message-ID: <20060817132828.41.eNlfeS4675.3636.michal@euridica.enternet.net.pl>
References: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964859AbWHQN2T@vger.kernel.org>
To: p_gortmaker@yahoo.com
Content-Disposition: inline
In-Reply-To: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>  
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>

diff -uprN -X linux-work/Documentation/dontdiff linux-work-clean/drivers/net/ne2k-pci.c linux-work2/drivers/net/ne2k-pci.c
--- linux-work-clean/drivers/net/ne2k-pci.c	2006-08-16 22:41:00.000000000 +0200
+++ linux-work2/drivers/net/ne2k-pci.c	2006-08-17 05:15:27.000000000 +0200
@@ -702,7 +702,7 @@ static int __init ne2k_pci_init(void)
 #ifdef MODULE
 	printk(version);
 #endif
-	return pci_module_init (&ne2k_driver);
+	return pci_register_driver(&ne2k_driver);
 }
 
 
