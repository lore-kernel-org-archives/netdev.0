From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: [RFC][PATCH 1/75] net: drivers/net/tokenring/3c359.c pci_module_init to pci_register_driver conversion
Date: Thu, 17 Aug 2006 13:26:40 +0000
Message-ID: <20060817132640.1.yoveaO3659.3636.michal@euridica.enternet.net.pl>
References: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from euridica.enternet.net.pl ([62.233.231.82]:27553 "EHLO
	euridica.enternet.net.pl") by vger.kernel.org with ESMTP
	id S932481AbWHQN0F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Aug 2006 09:26:05 -0400
To: mikep@linuxtr.net
Content-Disposition: inline
In-Reply-To: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>  
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>

diff -uprN -X linux-work/Documentation/dontdiff linux-work-clean/drivers/net/tokenring/3c359.c linux-work2/drivers/net/tokenring/3c359.c
--- linux-work-clean/drivers/net/tokenring/3c359.c	2006-08-16 22:41:00.000000000 +0200
+++ linux-work2/drivers/net/tokenring/3c359.c	2006-08-17 05:18:07.000000000 +0200
@@ -1815,7 +1815,7 @@ static struct pci_driver xl_3c359_driver
 
 static int __init xl_pci_init (void)
 {
-	return pci_module_init (&xl_3c359_driver);
+	return pci_register_driver(&xl_3c359_driver);
 }
 
 
