From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: [RFC][PATCH 58/75] net: drivers/net/sis900.c pci_module_init to pci_register_driver conversion
Date: Thu, 17 Aug 2006 13:29:21 +0000
Message-ID: <20060817132921.58.OysEZo5135.3636.michal@euridica.enternet.net.pl>
References: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from euridica.enternet.net.pl ([62.233.231.82]:21426 "EHLO
	euridica.enternet.net.pl") by vger.kernel.org with ESMTP
	id S964903AbWHQN2s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Aug 2006 09:28:48 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>  
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>

diff -uprN -X linux-work/Documentation/dontdiff linux-work-clean/drivers/net/sis900.c linux-work2/drivers/net/sis900.c
--- linux-work-clean/drivers/net/sis900.c	2006-08-16 22:41:00.000000000 +0200
+++ linux-work2/drivers/net/sis900.c	2006-08-17 05:16:32.000000000 +0200
@@ -2495,7 +2495,7 @@ static int __init sis900_init_module(voi
 	printk(version);
 #endif
 
-	return pci_module_init(&sis900_pci_driver);
+	return pci_register_driver(&sis900_pci_driver);
 }
 
 static void __exit sis900_cleanup_module(void)
