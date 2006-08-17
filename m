From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: [RFC][PATCH 10/75] net: drivers/net/bnx2.c pci_module_init to pci_register_driver conversion
Date: Thu, 17 Aug 2006 13:27:00 +0000
Message-ID: <20060817132700.10.oTCEXL3895.3636.michal@euridica.enternet.net.pl>
References: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964848AbWHQN6B@vger.kernel.org>
To: mchan@broadcom.com
Content-Disposition: inline
In-Reply-To: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>  
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>

diff -uprN -X linux-work/Documentation/dontdiff linux-work-clean/drivers/net/bnx2.c linux-work2/drivers/net/bnx2.c
--- linux-work-clean/drivers/net/bnx2.c	2006-08-16 22:41:17.000000000 +0200
+++ linux-work2/drivers/net/bnx2.c	2006-08-17 05:14:02.000000000 +0200
@@ -6015,7 +6015,7 @@ static struct pci_driver bnx2_pci_driver
 
 static int __init bnx2_init(void)
 {
-	return pci_module_init(&bnx2_pci_driver);
+	return pci_register_driver(&bnx2_pci_driver);
 }
 
 static void __exit bnx2_cleanup(void)
