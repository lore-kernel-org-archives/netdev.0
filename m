From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: [RFC][PATCH 24/75] net: drivers/net/wan/farsync.c pci_module_init to pci_register_driver conversion
Date: Thu, 17 Aug 2006 13:27:46 +0000
Message-ID: <20060817132746.24.PKHvKg4246.3636.michal@euridica.enternet.net.pl>
References: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964856AbWHQN1l@vger.kernel.org>
To: kevin.curtis@farsite.co.uk
Content-Disposition: inline
In-Reply-To: <20060817132638.0.iSIzDm3640.3636.michal@euridica.enternet.net.pl>  
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>

diff -uprN -X linux-work/Documentation/dontdiff linux-work-clean/drivers/net/wan/farsync.c linux-work2/drivers/net/wan/farsync.c
--- linux-work-clean/drivers/net/wan/farsync.c	2006-08-16 22:41:00.000000000 +0200
+++ linux-work2/drivers/net/wan/farsync.c	2006-08-17 05:19:37.000000000 +0200
@@ -2697,7 +2697,7 @@ fst_init(void)
 	for (i = 0; i < FST_MAX_CARDS; i++)
 		fst_card_array[i] = NULL;
 	spin_lock_init(&fst_work_q_lock);
-	return pci_module_init(&fst_driver);
+	return pci_register_driver(&fst_driver);
 }
 
 static void __exit
