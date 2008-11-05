From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH 0/6] SMSC LAN911x and LAN921x vendor driver
Date: Wed,  5 Nov 2008 10:35:36 +0000
Message-ID: <1225881342-3485-1-git-send-email-steve.glendinning@smsc.com>
Cc: catalin.marinas@arm.com, Bahadir.Balban@arm.com,
	dustin@sensoria.com, bgat@billgatliff.com,
	Ian Saturley <ian.saturley@smsc.com>, g.liakhovetski@gmx.de,
	Peter Korsgaard <jacmet@sunsite.dk>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [86.54.240.115] ([86.54.240.115]:57477 "EHLO drevil.shawell.net"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754230AbYKEKft (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Nov 2008 05:35:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset adds the smsc911x driver, and converts in-tree users of 
smc911x to use this driver instead.

I don't have access to all these development platforms (3x sh & ARM 
realview), so I've only been able to compile-test the changes so far.

The first patch (which adds the new driver) is identical to the last 
version posted for review.

Steve Glendinning (6):
  SMSC LAN911x and LAN921x vendor driver
  smsc911x: add dynamic bus configuration
  smsc911x: convert magicpanelr2 platform to use smsc911x
  smsc911x: convert ap325rxa platform to use smsc911x
  smsc911x: convert rsk7203 platform to use smsc911x
  smsc911x: convert realview platforms to use smsc911x

 MAINTAINERS                              |    6 +
 arch/arm/mach-realview/realview_eb.c     |   16 +-
 arch/arm/mach-realview/realview_pb1176.c |   13 +-
 arch/arm/mach-realview/realview_pb11mp.c |   13 +-
 arch/sh/boards/board-ap325rxa.c          |   24 +-
 arch/sh/boards/board-magicpanelr2.c      |   23 +-
 arch/sh/boards/board-rsk7203.c           |   24 +-
 arch/sh/configs/ap325rxa_defconfig       |   21 +-
 arch/sh/configs/magicpanelr2_defconfig   |   21 +-
 arch/sh/configs/rsk7203_defconfig        |   21 +-
 drivers/net/Kconfig                      |   14 +
 drivers/net/Makefile                     |    1 +
 drivers/net/phy/smsc.c                   |   28 +
 drivers/net/smsc911x.c                   | 2091 ++++++++++++++++++++++++++++++
 drivers/net/smsc911x.h                   |  393 ++++++
 include/linux/smsc911x.h                 |   47 +
 16 files changed, 2717 insertions(+), 39 deletions(-)
 create mode 100644 drivers/net/smsc911x.c
 create mode 100644 drivers/net/smsc911x.h
 create mode 100644 include/linux/smsc911x.h

