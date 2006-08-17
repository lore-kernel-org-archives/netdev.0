From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: [RFC][PATCH 6/75] net: drivers/net/amd8111e.c pci_module_init to pci_register_driver conversion
Date: Thu, 17 Aug 2006 13:26:52 +0000
Message-ID: <20060817132652.6.cLyUtH3793.3636.michal@euridica.enternet.net.pl>
References: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from euridica.enternet.net.pl ([62.233.231.82]:19618 "EHLO
	euridica.enternet.net.pl") by vger.kernel.org with ESMTP
	id S964911AbWHQN2l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Aug 2006 09:28:41 -0400
To: jgarzik@pobox.com
Content-Disposition: inline
In-Reply-To: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>  
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>

diff -uprN -X linux-work/Documentation/dontdiff linux-work-clean/drivers/net/amd8111e.c linux-work2/drivers/net/amd8111e.c
--- linux-work-clean/drivers/net/amd8111e.c	2006-08-16 22:40:59.000000000 +0200
+++ linux-work2/drivers/net/amd8111e.c	2006-08-17 05:13:42.000000000 +0200
@@ -2158,7 +2158,7 @@ static struct pci_driver amd8111e_driver
 
 static int __init amd8111e_init(void)
 {
-	return pci_module_init(&amd8111e_driver);
+	return pci_register_driver(&amd8111e_driver);
 }
 
 static void __exit amd8111e_cleanup(void)
