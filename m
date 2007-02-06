From: akpm@linux-foundation.org
Subject: [patch 09/11] Remove unused kernel config option DLCI_COUNT
Date: Mon, 05 Feb 2007 16:31:06 -0800
Message-ID: <200702060032.l160W9s8004643@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	rpjday@mindspring.com, jeff@garzik.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:41477 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965161AbXBFAcX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Feb 2007 19:32:23 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Robert P. J. Day" <rpjday@mindspring.com>

Remove the unused kernel config option DLCI_COUNT.

Signed-off-by: Robert P. J. Day <rpjday@mindspring.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Jeff Garzik <jeff@garzik.org>
Cc: Krzysztof Halasa {khc@pm.waw.pl>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/wan/Kconfig |   11 -----------
 1 file changed, 11 deletions(-)

diff -puN drivers/net/wan/Kconfig~remove-unused-kernel-config-option-dlci_count drivers/net/wan/Kconfig
--- a/drivers/net/wan/Kconfig~remove-unused-kernel-config-option-dlci_count
+++ a/drivers/net/wan/Kconfig
@@ -357,17 +357,6 @@ config DLCI
 	  To compile this driver as a module, choose M here: the
 	  module will be called dlci.
 
-config DLCI_COUNT
-	int "Max open DLCI"
-	depends on DLCI
-	default "24"
-	help
-	  Maximal number of logical point-to-point frame relay connections
-	  (the identifiers of which are called DCLIs) that the driver can
-	  handle.
-
-	  The default is probably fine.
-
 config DLCI_MAX
 	int "Max DLCI per device"
 	depends on DLCI
_
