From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH] SSB: make it depend on PCI
Date: Thu,  6 Nov 2008 04:51:22 -0500
Message-ID: <1225965082-31462-1-git-send-email-vapier@gentoo.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:50557 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753356AbYKFJvY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Nov 2008 04:51:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since the SSB code requires PCI, set the Kconfig dependencies accordingly.
Also tweak the menu display so that the menu does not show up at all if
SSB is not possible.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 drivers/ssb/Kconfig |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/ssb/Kconfig b/drivers/ssb/Kconfig
index 307b1f6..f0a176a 100644
--- a/drivers/ssb/Kconfig
+++ b/drivers/ssb/Kconfig
@@ -1,10 +1,11 @@
-menu "Sonics Silicon Backplane"
-
 config SSB_POSSIBLE
 	bool
-	depends on HAS_IOMEM && HAS_DMA
+	depends on HAS_IOMEM && HAS_DMA && PCI
 	default y
 
+menu "Sonics Silicon Backplane"
+	depends on SSB_POSSIBLE
+
 config SSB
 	tristate "Sonics Silicon Backplane support"
 	depends on SSB_POSSIBLE
-- 
1.6.0.3

