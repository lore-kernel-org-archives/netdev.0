From: Baruch Even <baruch@ev-en.org>
Subject: [PATCH] Hostess SV-11 depends on INET
Date: Sat, 17 Feb 2007 16:37:52 +0200
Message-ID: <20070217143752.GF25760@galon.ev-en.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-123-59-149.central.biz.rr.com ([24.123.59.149]:43197
	"EHLO galon.ev-en.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965258AbXBQOhx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Feb 2007 09:37:53 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Comtrol Hostess SV-11 driver uses features from INET but doesn't depend on it.
The simple solution is to make it depend on INET as happens for the sealevel
driver.

Fixes bug #7930.

Signed-Off-By: Baruch Even <baruch@ev-en.org>

Index: 2.6-gt/drivers/net/wan/Kconfig
===================================================================
--- 2.6-gt.orig/drivers/net/wan/Kconfig	2007-02-17 16:26:22.000000000 +0200
+++ 2.6-gt/drivers/net/wan/Kconfig	2007-02-17 16:26:27.000000000 +0200
@@ -26,7 +26,7 @@
 # There is no way to detect a comtrol sv11 - force it modular for now.
 config HOSTESS_SV11
 	tristate "Comtrol Hostess SV-11 support"
-	depends on WAN && ISA && m && ISA_DMA_API
+	depends on WAN && ISA && m && ISA_DMA_API && INET
 	help
 	  Driver for Comtrol Hostess SV-11 network card which
 	  operates on low speed synchronous serial links at up to
