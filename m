From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: [RFC][PATCH 11/75] net: drivers/net/cassini.c pci_module_init to pci_register_driver conversion
Date: Thu, 17 Aug 2006 13:27:04 +0000
Message-ID: <20060817132704.11.KHnhyW3917.3636.michal@euridica.enternet.net.pl>
References: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from euridica.enternet.net.pl ([62.233.231.82]:38049 "EHLO
	euridica.enternet.net.pl") by vger.kernel.org with ESMTP
	id S932504AbWHQN0g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Aug 2006 09:26:36 -0400
To: asun@darksunrising.com
Content-Disposition: inline
In-Reply-To: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>  
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>

diff -uprN -X linux-work/Documentation/dontdiff linux-work-clean/drivers/net/cassini.c linux-work2/drivers/net/cassini.c
--- linux-work-clean/drivers/net/cassini.c	2006-08-16 22:41:17.000000000 +0200
+++ linux-work2/drivers/net/cassini.c	2006-08-17 05:14:07.000000000 +0200
@@ -5245,7 +5245,7 @@ static int __init cas_init(void)
 	else
 		link_transition_timeout = 0;
 
-	return pci_module_init(&cas_driver);
+	return pci_register_driver(&cas_driver);
 }
 
 static void __exit cas_cleanup(void)
