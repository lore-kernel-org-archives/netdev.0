From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: [RFC][PATCH 70/75] net: drivers/net/via-rhine.c pci_module_init to pci_register_driver conversion
Date: Thu, 17 Aug 2006 13:29:49 +0000
Message-ID: <20060817132949.70.vAMjdA5456.3636.michal@euridica.enternet.net.pl>
References: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964931AbWHQNbY@vger.kernel.org>
To: rl@hellgate.ch
Content-Disposition: inline
In-Reply-To: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>  
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>

diff -uprN -X linux-work/Documentation/dontdiff linux-work-clean/drivers/net/via-rhine.c linux-work2/drivers/net/via-rhine.c
--- linux-work-clean/drivers/net/via-rhine.c	2006-08-16 22:41:17.000000000 +0200
+++ linux-work2/drivers/net/via-rhine.c	2006-08-17 05:19:18.000000000 +0200
@@ -2005,7 +2005,7 @@ static int __init rhine_init(void)
 #ifdef MODULE
 	printk(version);
 #endif
-	return pci_module_init(&rhine_driver);
+	return pci_register_driver(&rhine_driver);
 }
 
 
