From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: [RFC][PATCH 43/75] net: drivers/net/tokenring/olympic.c pci_module_init to pci_register_driver conversion
Date: Thu, 17 Aug 2006 13:28:32 +0000
Message-ID: <20060817132832.43.kWltTh4713.3636.michal@euridica.enternet.net.pl>
References: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964883AbWHQN2S@vger.kernel.org>
To: mikep@linuxtr.net
Content-Disposition: inline
In-Reply-To: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>  
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>

diff -uprN -X linux-work/Documentation/dontdiff linux-work-clean/drivers/net/tokenring/olympic.c linux-work2/drivers/net/tokenring/olympic.c
--- linux-work-clean/drivers/net/tokenring/olympic.c	2006-08-16 22:41:00.000000000 +0200
+++ linux-work2/drivers/net/tokenring/olympic.c	2006-08-17 05:18:24.000000000 +0200
@@ -1771,7 +1771,7 @@ static struct pci_driver olympic_driver 
 
 static int __init olympic_pci_init(void) 
 {
-	return pci_module_init (&olympic_driver) ; 
+	return pci_register_driver(&olympic_driver);
 }
 
 static void __exit olympic_pci_cleanup(void)
