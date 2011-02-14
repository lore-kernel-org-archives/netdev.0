From: panduranga_mallireddy@ti.com
Subject: [PATCH 2/5] omap: select REGULATOR_FIXED_VOLTAGE by default for panda and sdp4430
Date: Mon, 14 Feb 2011 02:19:15 -0500
Message-ID: <1297667958-22377-3-git-send-email-panduranga_mallireddy@ti.com>
References: <1297667958-22377-1-git-send-email-panduranga_mallireddy@ti.com>
 <1297667958-22377-2-git-send-email-panduranga_mallireddy@ti.com>
Cc: ohad@wizery.com, benzyg@ti.com, pradeepgurumath@ti.com,
	vishalm@ti.com, x-boudet@ti.com, naveen_jain@ti.com,
	pavan_savoy@ti.com, manjunatha_halli@ti.com, tony@atomide.com,
	cjb@laptop.org,
	Panduranga Mallireddy <panduranga_mallireddy@ti.com>
To: coelho@ti.com, netdev@vger.kernel.org, linux-omap@vger.kernel.org,
	linux-mmc@vger.kernel.org
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1297667958-22377-2-git-send-email-panduranga_mallireddy@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Panduranga Mallireddy <panduranga_mallireddy@ti.com>

Power to the wl12xx wlan device is controlled by a fixed regulator.
Boards that have the wl12xx should select REGULATOR_FIXED_VOLTAGE.
Signed-off-by: Panduranga Mallireddy <panduranga_mallireddy@ti.com>
---
 arch/arm/mach-omap2/Kconfig |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/arch/arm/mach-omap2/Kconfig b/arch/arm/mach-omap2/Kconfig
index 1a2cf62..eeaeb3b 100644
--- a/arch/arm/mach-omap2/Kconfig
+++ b/arch/arm/mach-omap2/Kconfig
@@ -300,6 +300,7 @@ config MACH_OMAP_4430SDP
 	depends on ARCH_OMAP4
 	select OMAP_PACKAGE_CBL
 	select OMAP_PACKAGE_CBS
+	select REGULATOR_FIXED_VOLTAGE
 
 config MACH_OMAP4_PANDA
 	bool "OMAP4 Panda Board"
@@ -307,6 +308,7 @@ config MACH_OMAP4_PANDA
 	depends on ARCH_OMAP4
 	select OMAP_PACKAGE_CBL
 	select OMAP_PACKAGE_CBS
+	select REGULATOR_FIXED_VOLTAGE
 
 config OMAP3_EMU
 	bool "OMAP3 debugging peripherals"
-- 
1.5.6.3

