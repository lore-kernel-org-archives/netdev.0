From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH REPOST 0/5] convert arm platforms to smsc911x
Date: Thu, 15 Jan 2009 09:07:57 +0000
Message-ID: <1232010482-3744-1-git-send-email-steve.glendinning@smsc.com>
Cc: David Miller <davem@davemloft.net>,
	Russell King <linux@arm.linux.org.uk>,
	Stanley Miao <stanley.miao@windriver.com>,
	Ian Saturley <ian.saturley@smsc.com>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from drevil.shawell.net ([86.54.240.115]:49014 "EHLO
	drevil2.shawell.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755291AbZAOJHT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 04:07:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset, intended for 2.6.30, converts all in-tree arm platforms 
from smc911x to the actively maintained smsc911x driver.

I don't have any of these platforms available to me, so I've only been 
able to compile-test the changes.

David Miller is planning to take the smsc911x patches via net-2.6, but 
I've included them here to make testing easier as the other patches in 
the set depend on them.

This patchset supercedes previous irq_flags patches from me and Stanley 
Miao.

Steve Glendinning (5):
  smsc911x: add support for platform-specific irq flags
  smsc911x: register isr as IRQF_SHARED
  arm: convert pcm037 platform to use smsc911x
  arm: convert realview platform to use smsc911x
  arm: convert omap ldp platform to use smsc911x

 arch/arm/configs/omap_ldp_defconfig         |   24 ++++++++++++++-
 arch/arm/configs/pcm037_defconfig           |   23 ++++++++++++++-
 arch/arm/configs/realview-smp_defconfig     |   24 ++++++++++++++-
 arch/arm/configs/realview_defconfig         |   24 ++++++++++++++-
 arch/arm/mach-mx3/pcm037.c                  |   22 ++++++++------
 arch/arm/mach-omap2/board-ldp.c             |   41 +++++++++++++++++----------
 arch/arm/mach-realview/core.c               |   17 ++++++-----
 arch/arm/plat-omap/include/mach/board-ldp.h |    4 +-
 drivers/net/smsc911x.c                      |   19 +++++++++---
 9 files changed, 151 insertions(+), 47 deletions(-)

