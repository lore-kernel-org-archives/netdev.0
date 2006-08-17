From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: [RFC][PATCH 73/75] net: drivers/net/tulip/winbond-840.c pci_module_init to pci_register_driver conversion
Date: Thu, 17 Aug 2006 13:29:55 +0000
Message-ID: <20060817132955.73.DThdtN5537.3636.michal@euridica.enternet.net.pl>
References: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from euridica.enternet.net.pl ([62.233.231.82]:36274 "EHLO
	euridica.enternet.net.pl") by vger.kernel.org with ESMTP
	id S964922AbWHQN3V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Aug 2006 09:29:21 -0400
To: becker@scyld.com
Content-Disposition: inline
In-Reply-To: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>  
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>

diff -uprN -X linux-work/Documentation/dontdiff linux-work-clean/drivers/net/tulip/winbond-840.c linux-work2/drivers/net/tulip/winbond-840.c
--- linux-work-clean/drivers/net/tulip/winbond-840.c	2006-08-16 22:41:17.000000000 +0200
+++ linux-work2/drivers/net/tulip/winbond-840.c	2006-08-17 05:19:02.000000000 +0200
@@ -1689,7 +1689,7 @@ static struct pci_driver w840_driver = {
 static int __init w840_init(void)
 {
 	printk(version);
-	return pci_module_init(&w840_driver);
+	return pci_register_driver(&w840_driver);
 }
 
 static void __exit w840_exit(void)
