From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: [RFC][PATCH 16/75] net: drivers/net/defxx.c pci_module_init to pci_register_driver conversion
Date: Thu, 17 Aug 2006 13:27:23 +0000
Message-ID: <20060817132723.16.nTqjEk4058.3636.michal@euridica.enternet.net.pl>
References: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964854AbWHQN1B@vger.kernel.org>
To: macro@linux-mips.org
Content-Disposition: inline
In-Reply-To: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>  
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>

diff -uprN -X linux-work/Documentation/dontdiff linux-work-clean/drivers/net/defxx.c linux-work2/drivers/net/defxx.c
--- linux-work-clean/drivers/net/defxx.c	2006-08-16 22:40:59.000000000 +0200
+++ linux-work2/drivers/net/defxx.c	2006-08-17 05:14:19.000000000 +0200
@@ -3444,7 +3444,7 @@ static int __init dfx_init(void)
 {
 	int rc_pci, rc_eisa;
 
-	rc_pci = pci_module_init(&dfx_driver);
+	rc_pci = pci_register_driver(&dfx_driver);
 	if (rc_pci >= 0) dfx_have_pci = 1;
 	
 	rc_eisa = dfx_eisa_init();
