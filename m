From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH 7/8] isdn: replace CONFIG_8xx by CONFIG_PPC_8xx
Date: Thu, 12 Mar 2015 16:24:09 +0100 (CET)
Message-ID: <20150312152409.E7B5C1A2422@localhost.localdomain>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	user-mode-linux-devel@lists.sourceforge.net,
	user-mode-linux-user@lists.sourceforge.net,
	linux-fbdev@vger.kernel.org, netdev@vger.kernel.org,
	linux-serial@vger.kernel.org, linux-mtd@lists.infradead.org
To: Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pegase1.c-s.fr ([93.17.236.30]:10582 "EHLO mailhub1.si.c-s.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932196AbbCLPfm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Mar 2015 11:35:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Two config options exist to define powerpc MPC8xx:
* CONFIG_PPC_8xx
* CONFIG_8xx
In addition, CONFIG_PPC_8xx also defines CONFIG_CPM1 as
communication co-processor

arch/powerpc/platforms/Kconfig.cputype has contained the following
comment about CONFIG_8xx item for some years:
"# this is temp to handle compat with arch=ppc"

It looks like not many places still have that old CONFIG_8xx used,
so it is likely to be a good time to get rid of it completely ?

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>

---
 drivers/isdn/hardware/mISDN/Kconfig | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/isdn/hardware/mISDN/Kconfig b/drivers/isdn/hardware/mISDN/Kconfig
index 09df54f..ad9deab 100644
--- a/drivers/isdn/hardware/mISDN/Kconfig
+++ b/drivers/isdn/hardware/mISDN/Kconfig
@@ -13,7 +13,7 @@ config MISDN_HFCPCI
 
 config MISDN_HFCMULTI
 	tristate "Support for HFC multiport cards (HFC-4S/8S/E1)"
-	depends on PCI || 8xx
+	depends on PCI || PPC_8xx
 	depends on MISDN
 	help
 	  Enable support for cards with Cologne Chip AG's HFC multiport
@@ -28,7 +28,7 @@ config MISDN_HFCMULTI_8xx
 	depends on MISDN
 	depends on MISDN_HFCMULTI
 	depends on 8xx
-	default 8xx
+	default PPC_8xx
 	help
 	  Enable support for the XHFC embedded solution from Speech Design.
 
-- 
2.1.0
