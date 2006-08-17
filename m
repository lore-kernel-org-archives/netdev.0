From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: [RFC][PATCH 28/75] net: drivers/net/hp100.c pci_module_init to pci_register_driver conversion
Date: Thu, 17 Aug 2006 13:27:56 +0000
Message-ID: <20060817132756.28.huuPOV4353.3636.michal@euridica.enternet.net.pl>
References: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from euridica.enternet.net.pl ([62.233.231.82]:56225 "EHLO
	euridica.enternet.net.pl") by vger.kernel.org with ESMTP
	id S964860AbWHQN10 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Aug 2006 09:27:26 -0400
To: perex@suse.cz
Content-Disposition: inline
In-Reply-To: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>  
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>

diff -uprN -X linux-work/Documentation/dontdiff linux-work-clean/drivers/net/hp100.c linux-work2/drivers/net/hp100.c
--- linux-work-clean/drivers/net/hp100.c	2006-08-16 22:41:17.000000000 +0200
+++ linux-work2/drivers/net/hp100.c	2006-08-17 05:15:07.000000000 +0200
@@ -3031,7 +3031,7 @@ static int __init hp100_module_init(void
 		goto out2;
 #endif
 #ifdef CONFIG_PCI
-	err = pci_module_init(&hp100_pci_driver);
+	err = pci_register_driver(&hp100_pci_driver);
 	if (err && err != -ENODEV) 
 		goto out3;
 #endif
