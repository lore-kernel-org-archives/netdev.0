From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 6/5] cpmac: unmark as broken
Date: Tue, 4 Aug 2009 23:17:49 +0200
Message-ID: <200908042317.49497.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f214.google.com ([209.85.219.214]:37162 "EHLO
	mail-ew0-f214.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932578AbZHDVRw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2009 17:17:52 -0400
Received: by ewy10 with SMTP id 10so670724ewy.37
        for <netdev@vger.kernel.org>; Tue, 04 Aug 2009 14:17:52 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

I realised afterwards that unmarking cpmac as BROKEN
should have been part of the previous patch series that I sent.

Sorry about that.
--
From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 6/5] cpmac: unmark as broken

Starting with version 0.5.1, cpmac is no longer broken.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 5f6509a..9948fa2 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1774,7 +1774,7 @@ config SC92031
 
 config CPMAC
 	tristate "TI AR7 CPMAC Ethernet support (EXPERIMENTAL)"
-	depends on NET_ETHERNET && EXPERIMENTAL && AR7 && BROKEN
+	depends on NET_ETHERNET && EXPERIMENTAL && AR7
 	select PHYLIB
 	help
 	  TI AR7 CPMAC Ethernet support
