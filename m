From: Guennadi Liakhovetski <g.liakhovetski@gmx.de>
Subject: [PATCH 0/4] net: smsc911x: support reset GPIO and use it on ape6evm
Date: Tue, 23 Jul 2013 18:12:00 +0200
Message-ID: <1374595924-12338-1-git-send-email-g.liakhovetski@gmx.de>
Cc: Magnus Damm <magnus.damm@gmail.com>,
	Simon Horman <horms@verge.net.au>,
	Steve Glendinning <steve.glendinning@shawell.net>,
	netdev@vger.kernel.org,
	Guennadi Liakhovetski <g.liakhovetski+renesas@gmail.com>
To: linux-sh@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:56106 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933543Ab3GWQMI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 12:12:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The first two patches add support for a reset GPIO to the smsc911x driver
in the platform data and in DT. The latter 2 patches use the reset GPIO
on APE6EVM in DT and non-DT modes. They therefore should be applied after
the first two patches are merged.

Cc: Guennadi Liakhovetski <g.liakhovetski+renesas@gmail.com>

Guennadi Liakhovetski (4):
  net: smsc911x: add support for a reset GPIO
  net: smsc911x: add a reset GPIO DT binding
  ARM: shmobile: ape6evm: use smsc911x platform parameters to handle
    eth reset
  ARM: shmobile: ape6evm-reference: add smsc911x ethernet support

 Documentation/devicetree/bindings/net/smsc911x.txt |    1 +
 arch/arm/boot/dts/r8a73a4-ape6evm-reference.dts    |   25 ++++++++++++++++-
 arch/arm/mach-shmobile/board-ape6evm.c             |    5 +--
 drivers/net/ethernet/smsc/smsc911x.c               |   30 +++++++++++++++++++-
 include/linux/smsc911x.h                           |   10 ++++++
 5 files changed, 66 insertions(+), 5 deletions(-)

-- 
1.7.2.5

Thanks
Guennadi
---
Guennadi Liakhovetski, Ph.D.
Freelance Open-Source Software Developer
http://www.open-technology.de/
