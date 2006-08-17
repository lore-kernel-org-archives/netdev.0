From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: [RFC][PATCH 25/75] net: drivers/net/fealnx.c module_init to pci_register_driver conversion
Date: Thu, 17 Aug 2006 13:27:50 +0000
Message-ID: <20060817132750.25.yenkew4276.3636.michal@euridica.enternet.net.pl>
References: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from euridica.enternet.net.pl ([62.233.231.82]:52129 "EHLO
	euridica.enternet.net.pl") by vger.kernel.org with ESMTP
	id S964861AbWHQN1R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Aug 2006 09:27:17 -0400
To: becker@scyld.com
Content-Disposition: inline
In-Reply-To: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>  
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>

diff -uprN -X linux-work/Documentation/dontdiff linux-work-clean/drivers/net/fealnx.c linux-work2/drivers/net/fealnx.c
--- linux-work-clean/drivers/net/fealnx.c	2006-08-16 22:41:17.000000000 +0200
+++ linux-work2/drivers/net/fealnx.c	2006-08-17 05:14:55.000000000 +0200
@@ -1984,7 +1984,7 @@ static int __init fealnx_init(void)
 	printk(version);
 #endif
 
-	return pci_module_init(&fealnx_driver);
+	return pci_register_driver(&fealnx_driver);
 }
 
 static void __exit fealnx_exit(void)
