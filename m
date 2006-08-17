From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: [RFC][PATCH 53/75] net: drivers/net/r8169.c pci_module_init to pci_register_driver conversion
Date: Thu, 17 Aug 2006 13:29:02 +0000
Message-ID: <20060817132902.53.iGyoRk5003.3636.michal@euridica.enternet.net.pl>
References: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from euridica.enternet.net.pl ([62.233.231.82]:14498 "EHLO
	euridica.enternet.net.pl") by vger.kernel.org with ESMTP
	id S964897AbWHQN20 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Aug 2006 09:28:26 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>  
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>

diff -uprN -X linux-work/Documentation/dontdiff linux-work-clean/drivers/net/r8169.c linux-work2/drivers/net/r8169.c
--- linux-work-clean/drivers/net/r8169.c	2006-08-16 22:41:17.000000000 +0200
+++ linux-work2/drivers/net/r8169.c	2006-08-17 05:15:58.000000000 +0200
@@ -2910,7 +2910,7 @@ static struct pci_driver rtl8169_pci_dri
 static int __init
 rtl8169_init_module(void)
 {
-	return pci_module_init(&rtl8169_pci_driver);
+	return pci_register_driver(&rtl8169_pci_driver);
 }
 
 static void __exit
