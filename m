From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: [RFC][PATCH 65/75] net: drivers/net/tc35815.c pci_module_init to pci_register_driver conversion
Date: Thu, 17 Aug 2006 13:29:37 +0000
Message-ID: <20060817132937.65.HKvqQP5317.3636.michal@euridica.enternet.net.pl>
References: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964933AbWHQN3U@vger.kernel.org>
To: ahennessy@mvista.com
Content-Disposition: inline
In-Reply-To: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>  
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>

diff -uprN -X linux-work/Documentation/dontdiff linux-work-clean/drivers/net/tc35815.c linux-work2/drivers/net/tc35815.c
--- linux-work-clean/drivers/net/tc35815.c	2006-08-16 22:41:00.000000000 +0200
+++ linux-work2/drivers/net/tc35815.c	2006-08-17 05:17:42.000000000 +0200
@@ -1725,7 +1725,7 @@ static struct pci_driver tc35815_driver 
 
 static int __init tc35815_init_module(void)
 {
-	return pci_module_init(&tc35815_driver);
+	return pci_register_driver(&tc35815_driver);
 }
 
 static void __exit tc35815_cleanup_module(void)
