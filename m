From: panduranga_mallireddy@ti.com
Subject: [PATCH 0/5] Panda: Support for WLAN on WL127x
Date: Mon, 14 Feb 2011 02:19:13 -0500
Message-ID: <1297667958-22377-1-git-send-email-panduranga_mallireddy@ti.com>
Cc: ohad@wizery.com, benzyg@ti.com, pradeepgurumath@ti.com,
	vishalm@ti.com, x-boudet@ti.com, naveen_jain@ti.com,
	pavan_savoy@ti.com, manjunatha_halli@ti.com, tony@atomide.com,
	cjb@laptop.org,
	Panduranga Mallireddy <panduranga_mallireddy@ti.com>
To: coelho@ti.com, netdev@vger.kernel.org, linux-omap@vger.kernel.org,
	linux-mmc@vger.kernel.org
Return-path: <linux-mmc-owner@vger.kernel.org>
Sender: linux-mmc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Panduranga Mallireddy <panduranga_mallireddy@ti.com>

Adding support for WLAN on Panda board using wl12xx and mac80211 drivers

Patches were tested on Panda board.

These patches add software control for emulating card detect events,
add board configurations to support the wl127x device.

These patches are dependent on the patches that enable clock for WLAN on panda.
Please refer the following links for these patches:
https://patchwork.kernel.org/patch/546381/
https://patchwork.kernel.org/patch/546401/

[PATCH 5/5] OMAP: hsmmc: Enable MMC4 and MMC5 on OMAP4 platforms
 is dependent on hwmod adpotation for HSMMC patches series.
For original patches of adpotation for HSMMC refer:
http://www.mail-archive.com/linux-omap@vger.kernel.org/msg43464.html

Patches are based on mainline 2.6.38-rc3

Kishore Kadiyala (1):
  OMAP: hsmmc: Enable MMC4 and MMC5 on OMAP4 platforms

Panduranga Mallireddy (4):
  omap: panda: wlan board muxing
  omap: select REGULATOR_FIXED_VOLTAGE by default for panda and sdp4430
  omap: panda: add fixed regulator device for wlan
  omap: panda: add mmc5/wl1271 device support

 arch/arm/mach-omap2/Kconfig            |    2 +
 arch/arm/mach-omap2/board-omap4panda.c |   67 ++++++++++++++++++++++++++++++++
 arch/arm/mach-omap2/hsmmc.c            |    5 ++
 drivers/mmc/host/omap_hsmmc.c          |   24 +++++++++--
 4 files changed, 94 insertions(+), 4 deletions(-)

