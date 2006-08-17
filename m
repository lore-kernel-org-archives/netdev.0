From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: [RFC][PATCH 5/75] net: drivers/net/acenic.c pci_module_init to pci_register_driver conversion
Date: Thu, 17 Aug 2006 13:26:50 +0000
Message-ID: <20060817132650.5.bPNCUZ3766.3636.michal@euridica.enternet.net.pl>
References: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from euridica.enternet.net.pl ([62.233.231.82]:34721 "EHLO
	euridica.enternet.net.pl") by vger.kernel.org with ESMTP
	id S932498AbWHQN0Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Aug 2006 09:26:24 -0400
To: jes@trained-monkey.org
Content-Disposition: inline
In-Reply-To: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>  
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>

diff -uprN -X linux-work/Documentation/dontdiff linux-work-clean/drivers/net/acenic.c linux-work2/drivers/net/acenic.c
--- linux-work-clean/drivers/net/acenic.c	2006-08-17 00:10:47.000000000 +0200
+++ linux-work2/drivers/net/acenic.c	2006-08-17 05:13:37.000000000 +0200
@@ -725,7 +725,7 @@ static struct pci_driver acenic_pci_driv
 
 static int __init acenic_init(void)
 {
-	return pci_module_init(&acenic_pci_driver);
+	return pci_register_driver(&acenic_pci_driver);
 }
 
 static void __exit acenic_exit(void)
