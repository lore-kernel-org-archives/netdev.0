From: Luis de Bethencourt <luisbg@osg.samsung.com>
Subject: [PATCH] ssb: extif: Compile with COMPILE_TEST
Date: Wed, 14 Oct 2015 17:33:30 +0100
Message-ID: <1444840410-31418-1-git-send-email-luisbg@osg.samsung.com>
Cc: m@bues.ch, netdev@vger.kernel.org, javier@osg.samsung.com,
	Luis de Bethencourt <luisbg@osg.samsung.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This driver only has runtime but no build time dependencies, so it can
be built for testing purposes if the Kconfig COMPILE_TEST option is enabled.

This is useful to have more build coverage and make sure that drivers are
not affected by changes that could cause build regressions. For example,
when building with allyesconfig.

Signed-off-by: Luis de Bethencourt <luisbg@osg.samsung.com>
---
 drivers/ssb/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/ssb/Kconfig b/drivers/ssb/Kconfig
index f0d22cd..1819a54 100644
--- a/drivers/ssb/Kconfig
+++ b/drivers/ssb/Kconfig
@@ -150,7 +150,7 @@ config SSB_EMBEDDED
 
 config SSB_DRIVER_EXTIF
 	bool "SSB Broadcom EXTIF core driver"
-	depends on SSB_DRIVER_MIPS
+	depends on SSB_DRIVER_MIPS || COMPILE_TEST
 	help
 	  Driver for the Sonics Silicon Backplane attached
 	  Broadcom EXTIF core.
-- 
2.5.1
