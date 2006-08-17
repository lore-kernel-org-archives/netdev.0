From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: [RFC][PATCH 17/75] net: drivers/net/dl2k.c pci_module_init to pci_register_driver conversion
Date: Thu, 17 Aug 2006 13:27:27 +0000
Message-ID: <20060817132727.17.eJLrXu4077.3636.michal@euridica.enternet.net.pl>
References: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from euridica.enternet.net.pl ([62.233.231.82]:44449 "EHLO
	euridica.enternet.net.pl") by vger.kernel.org with ESMTP
	id S964847AbWHQN05 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Aug 2006 09:26:57 -0400
To: edward_peng@dlink.com.tw
Content-Disposition: inline
In-Reply-To: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>  
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>

diff -uprN -X linux-work/Documentation/dontdiff linux-work-clean/drivers/net/dl2k.c linux-work2/drivers/net/dl2k.c
--- linux-work-clean/drivers/net/dl2k.c	2006-08-16 22:41:17.000000000 +0200
+++ linux-work2/drivers/net/dl2k.c	2006-08-17 05:14:25.000000000 +0200
@@ -1815,7 +1815,7 @@ static struct pci_driver rio_driver = {
 static int __init
 rio_init (void)
 {
-	return pci_module_init (&rio_driver);
+	return pci_register_driver(&rio_driver);
 }
 
 static void __exit
