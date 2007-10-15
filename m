From: Valentine Barshak <vbarshak@ru.mvista.com>
Subject: [PATCH] PowerPC: Enable NEW EMAC support for Sequoia 440EPx.
Date: Mon, 15 Oct 2007 21:58:37 +0400
Message-ID: <20071015175837.GA4631@ru.mvista.com>
References: <20071015122616.08250b54@weaponx.rchland.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jwboyer@linux.vnet.ibm.com
To: linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [212.176.242.38] ([212.176.242.38]:59332 "EHLO
	vaxon.spb.rtsoft.ru" rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752989AbXJOSPM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 14:15:12 -0400
Content-Disposition: inline
In-Reply-To: <20071015122616.08250b54@weaponx.rchland.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch enables NEW EMAC support for PowerPC 440EPx Sequoia board.

Signed-off-by: Valentine Barshak <vbarshak@ru.mvista.com>
---
 arch/powerpc/platforms/44x/Kconfig |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

--- linux.orig/arch/powerpc/platforms/44x/Kconfig	2007-07-30 15:05:50.000000000 +0400
+++ linux/arch/powerpc/platforms/44x/Kconfig	2007-07-30 17:59:05.000000000 +0400
@@ -48,10 +48,9 @@
 config 440EPX
 	bool
 	select PPC_FPU
-# Disabled until the new EMAC Driver is merged.
-#	select IBM_NEW_EMAC_EMAC4
-#	select IBM_NEW_EMAC_RGMII
-#	select IBM_NEW_EMAC_ZMII
+	select IBM_NEW_EMAC_EMAC4
+	select IBM_NEW_EMAC_RGMII
+	select IBM_NEW_EMAC_ZMII
 
 config 440GP
 	bool
