From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: [RFC][PATCH 62/75] net: drivers/net/starfire.c pci_module_init to pci_register_driver conversion
Date: Thu, 17 Aug 2006 13:29:32 +0000
Message-ID: <20060817132932.62.DSvssd5251.3636.michal@euridica.enternet.net.pl>
References: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964968AbWHQNiH@vger.kernel.org>
To: ionut@badula.org
Content-Disposition: inline
In-Reply-To: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>  
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>

diff -uprN -X linux-work/Documentation/dontdiff linux-work-clean/drivers/net/starfire.c linux-work2/drivers/net/starfire.c
--- linux-work-clean/drivers/net/starfire.c	2006-08-16 22:41:17.000000000 +0200
+++ linux-work2/drivers/net/starfire.c	2006-08-17 05:17:15.000000000 +0200
@@ -2053,7 +2053,7 @@ static int __init starfire_init (void)
 		return -ENODEV;
 	}
 
-	return pci_module_init (&starfire_driver);
+	return pci_register_driver(&starfire_driver);
 }
 
 
