From: Jean Delvare <jdelvare@suse.de>
Subject: [PATCH 2/2] isdn: hisax: Drop duplicate Kconfig entry
Date: Mon, 16 Jun 2014 10:13:55 +0200
Message-ID: <1402906435.13305.6.camel@chaos.site>
References: <1402906177.13305.1.camel@chaos.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Karsten Keil <isdn@linux-pingi.de>, Sam Ravnborg <sam@ravnborg.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:52311 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754183AbaFPIN6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jun 2014 04:13:58 -0400
In-Reply-To: <1402906177.13305.1.camel@chaos.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are 2 HISAX_AVM_A1_PCMCIA Kconfig entries. The kbuild system
ignores the second one, and apparently nobody noticed the problem so
far, so let's remove that second entry.

Signed-off-by: Jean Delvare <jdelvare@suse.de>
Cc: Karsten Keil <isdn@linux-pingi.de>
---
 drivers/isdn/hisax/Kconfig |    5 -----
 1 file changed, 5 deletions(-)

--- a/drivers/isdn/hisax/Kconfig
+++ b/drivers/isdn/hisax/Kconfig
@@ -416,11 +416,6 @@ config HISAX_FRITZ_PCIPNP
 	  (the latter also needs you to select "ISA Plug and Play support"
 	  from the menu "Plug and Play configuration")
 
-config HISAX_AVM_A1_PCMCIA
-	bool
-	depends on HISAX_AVM_A1_CS
-	default y
-
 endif
 
 endmenu

-- 
Jean Delvare
SUSE L3 Support
