From: Richard Knutsson <ricknu-0@student.ltu.se>
Subject: [PATCH] net/wan/pc300too.c: pci_module_init to pci_register_driver
Date: Wed, 14 Feb 2007 01:40:21 +0100 (MET)
Message-ID: <20070214004022.4455.49724.sendpatchset@thinktank.campus.ltu.se>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Richard Knutsson <ricknu-0@student.ltu.se>
To: Krzysztof Halasa <khc@pm.waw.pl>, Andrew Morton <akpm@osdl.org>,
	Jeff Garzik <jeff@garzik.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932114AbXBNAkq@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert pci_module_init() to pci_register_driver().

Signed-off-by: Richard Knutsson <ricknu-0@student.ltu.se>
---
Compile-tested with "allyes", "allmod" & "allno" on i386


diff --git a/drivers/net/wan/pc300too.c b/drivers/net/wan/pc300too.c
index bc156b5..aff05db 100644
--- a/drivers/net/wan/pc300too.c
+++ b/drivers/net/wan/pc300too.c
@@ -542,7 +542,7 @@ static int __init pc300_init_module(void)
 
 	CLOCK_BASE = use_crystal_clock ? 24576000 : pci_clock_freq;
 
-	return pci_module_init(&pc300_pci_driver);
+	return pci_register_driver(&pc300_pci_driver);
 }
 
 
