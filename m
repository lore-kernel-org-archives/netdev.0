From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: [RFC][PATCH 50/75] net: drivers/net/wan/pci200syn.c pci_module_init to pci_register_driver conversion
Date: Thu, 17 Aug 2006 13:28:54 +0000
Message-ID: <20060817132854.50.mHRHNx4920.3636.michal@euridica.enternet.net.pl>
References: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964905AbWHQNoA@vger.kernel.org>
To: khc@pm.waw.pl
Content-Disposition: inline
In-Reply-To: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>  
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>

diff -uprN -X linux-work/Documentation/dontdiff linux-work-clean/drivers/net/wan/pci200syn.c linux-work2/drivers/net/wan/pci200syn.c
--- linux-work-clean/drivers/net/wan/pci200syn.c	2006-08-16 22:41:00.000000000 +0200
+++ linux-work2/drivers/net/wan/pci200syn.c	2006-08-17 05:19:56.000000000 +0200
@@ -476,7 +476,7 @@ static int __init pci200_init_module(voi
 		printk(KERN_ERR "pci200syn: Invalid PCI clock frequency\n");
 		return -EINVAL;
 	}
-	return pci_module_init(&pci200_pci_driver);
+	return pci_register_driver(&pci200_pci_driver);
 }
 
 
