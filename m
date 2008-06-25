From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] remove the unused APOLLO_ELPLUS option
Date: Wed, 25 Jun 2008 19:24:54 +0300
Message-ID: <20080625162454.GB10285@cs181140183.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, "Robert P. J. Day" <rpjday@crashcourse.ca>,
	linux-m68k@lists.linux-m68k.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6.pp.htv.fi ([213.243.153.40]:42891 "EHLO smtp6.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751476AbYFYQ06 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jun 2008 12:26:58 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Looking at older kernel sources the APOLLO_ELPLUS option was added 
somewhere during kernel 2.1, but even kernel 2.2.0 does not contain
any driver that would be enabled through it...

Reported-by: Robert P. J. Day <rpjday@crashcourse.ca>
Signed-off-by: Adrian Bunk <bunk@kernel.org>

---
da9c97ae1bc6780bf484040e7160b8344cbe730f diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index f4182cf..5598783 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -333,15 +333,6 @@ config APNE
 	  To compile this driver as a module, choose M here: the module
 	  will be called apne.
 
-config APOLLO_ELPLUS
-	tristate "Apollo 3c505 support"
-	depends on APOLLO
-	help
-	  Say Y or M here if your Apollo has a 3Com 3c505 ISA Ethernet card.
-	  If you don't have one made for Apollos, you can use one from a PC,
-	  except that your Apollo won't be able to boot from it (because the
-	  code in the ROM will be for a PC).
-
 config MAC8390
 	bool "Macintosh NS 8390 based ethernet cards"
 	depends on MAC

