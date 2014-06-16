From: Jean Delvare <jdelvare@suse.de>
Subject: [PATCH 1/2] isdn: hisax: Merge Kconfig ifs
Date: Mon, 16 Jun 2014 10:09:37 +0200
Message-ID: <1402906177.13305.1.camel@chaos.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Karsten Keil <isdn@linux-pingi.de>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:52254 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752152AbaFPIJk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jun 2014 04:09:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The first half of the HiSax config options is presented if
ISDN_DRV_HISAX!=n, while the second half of the options is presented
if ISDN_DRV_HISAX. That's the same, so merge both conditionals.

Signed-off-by: Jean Delvare <jdelvare@suse.de>
Cc: Karsten Keil <isdn@linux-pingi.de>
---
 drivers/isdn/hisax/Kconfig |    6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

--- a/drivers/isdn/hisax/Kconfig
+++ b/drivers/isdn/hisax/Kconfig
@@ -16,7 +16,7 @@ config ISDN_DRV_HISAX
 	  also to the configuration option of the driver for your particular
 	  card, below.
 
-if ISDN_DRV_HISAX!=n
+if ISDN_DRV_HISAX
 
 comment "D-channel protocol features"
 
@@ -348,10 +348,6 @@ config HISAX_ENTERNOW_PCI
 	  This enables HiSax support for the Formula-n enter:now PCI
 	  ISDN card.
 
-endif
-
-if ISDN_DRV_HISAX
-
 config HISAX_DEBUG
 	bool "HiSax debugging"
 	help

-- 
Jean Delvare
SUSE L3 Support
