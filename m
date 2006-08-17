From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: [RFC][PATCH 22/75] net: drivers/net/eepro100.c pci_module_init to pci_register_driver conversion
Date: Thu, 17 Aug 2006 13:27:41 +0000
Message-ID: <20060817132741.22.yzQssS4186.3636.michal@euridica.enternet.net.pl>
References: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from euridica.enternet.net.pl ([62.233.231.82]:51617 "EHLO
	euridica.enternet.net.pl") by vger.kernel.org with ESMTP
	id S964859AbWHQN1P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Aug 2006 09:27:15 -0400
To: saw@saw.sw.com.sg
Content-Disposition: inline
In-Reply-To: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>  
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>

diff -uprN -X linux-work/Documentation/dontdiff linux-work-clean/drivers/net/eepro100.c linux-work2/drivers/net/eepro100.c
--- linux-work-clean/drivers/net/eepro100.c	2006-08-16 22:41:00.000000000 +0200
+++ linux-work2/drivers/net/eepro100.c	2006-08-17 05:14:42.000000000 +0200
@@ -2385,7 +2385,7 @@ static int __init eepro100_init_module(v
 #ifdef MODULE
 	printk(version);
 #endif
-	return pci_module_init(&eepro100_driver);
+	return pci_register_driver(&eepro100_driver);
 }
 
 static void __exit eepro100_cleanup_module(void)
