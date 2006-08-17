From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: [RFC][PATCH 71/75] net: drivers/net/via-velocity.c pci_module_init to pci_register_driver conversion
Date: Thu, 17 Aug 2006 13:29:51 +0000
Message-ID: <20060817132951.71.IcshsS5487.3636.michal@euridica.enternet.net.pl>
References: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from euridica.enternet.net.pl ([62.233.231.82]:38834 "EHLO
	euridica.enternet.net.pl") by vger.kernel.org with ESMTP
	id S964945AbWHQN30 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Aug 2006 09:29:26 -0400
To: alan@redhat.com
Content-Disposition: inline
In-Reply-To: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>  
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>

diff -uprN -X linux-work/Documentation/dontdiff linux-work-clean/drivers/net/via-velocity.c linux-work2/drivers/net/via-velocity.c
--- linux-work-clean/drivers/net/via-velocity.c	2006-08-16 22:41:17.000000000 +0200
+++ linux-work2/drivers/net/via-velocity.c	2006-08-17 05:19:24.000000000 +0200
@@ -2250,7 +2250,7 @@ static int __init velocity_init_module(v
 	int ret;
 
 	velocity_register_notifier();
-	ret = pci_module_init(&velocity_driver);
+	ret = pci_register_driver(&velocity_driver);
 	if (ret < 0)
 		velocity_unregister_notifier();
 	return ret;
