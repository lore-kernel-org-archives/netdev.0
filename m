From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCHv3 00/10] convert arm platforms to smsc911x
Date: Tue, 27 Jan 2009 16:51:08 +0000
Message-ID: <1233075077-17205-1-git-send-email-steve.glendinning@smsc.com>
Cc: David Miller <davem@davemloft.net>,
	Russell King <linux@arm.linux.org.uk>,
	Stanley Miao <stanley.miao@windriver.com>,
	Ian Saturley <ian.saturley@smsc.com>,
	Mark Brown <broonie@opensource.wolfsonmicro.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [86.54.240.114] ([86.54.240.114]:53189 "EHLO
	kensington.shawell.net" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755413AbZA0QvL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 11:51:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset, intended for 2.6.30, converts in-tree arm platforms from
smc911x to the actively maintained smsc911x driver.

The platform updates (5-7) depend on the driver updates (1-4) for 
correct operation, so David Miller is planning to take these via the 
net-2.6 tree.  Defconfig updates have been split out (8-10) for merging 
via the arm tree.

Stanley.Miao (1):
  arm: update omap_ldp defconfig to use smsc911x

Steve Glendinning (9):
  smsc911x: add support for platform-specific irq flags
  smsc911x: register isr as IRQF_SHARED
  smsc911x: add external phy detection overrides
  smsc911x: allow mac address to be saved before device reset
  arm: convert pcm037 platform to use smsc911x
  arm: convert realview platform to use smsc911x
  arm: convert omap ldp platform to use smsc911x
  arm: update pcm037 defconfig to use smsc911x
  arm: update realview defconfigs to use smsc911x

 arch/arm/configs/omap_ldp_defconfig         |   24 +++++-
 arch/arm/configs/pcm037_defconfig           |   23 +++++-
 arch/arm/configs/realview-smp_defconfig     |   24 +++++-
 arch/arm/configs/realview_defconfig         |   24 +++++-
 arch/arm/mach-mx3/pcm037.c                  |   23 +++--
 arch/arm/mach-omap2/board-ldp.c             |   49 ++++++-----
 arch/arm/mach-realview/core.c               |   17 ++--
 arch/arm/plat-omap/include/mach/board-ldp.h |    6 +-
 drivers/net/smsc911x.c                      |  124 ++++++++++++++++-----------
 include/linux/smsc911x.h                    |    3 +
 10 files changed, 218 insertions(+), 99 deletions(-)

