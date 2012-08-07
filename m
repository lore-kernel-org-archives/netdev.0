From: Ian Molton <ian.molton@codethink.co.uk>
Subject: [PATCH v3 0/7] mv643xx.c: Add basic device tree support.
Date: Tue,  7 Aug 2012 15:34:45 +0100
Message-ID: <1344350092-24050-1-git-send-email-ian.molton@codethink.co.uk>
Cc: andrew@lunn.ch, thomas.petazzoni@free-electrons.com,
	ben.dooks@codethink.co.uk, arnd@arndb.de, netdev@vger.kernel.org
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([37.128.190.40]:50800 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754751Ab2HGOfH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2012 10:35:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixed all comments.

* Dropped csb1724 defconfig.
* Added patch to remove MV643XX_ETH_SHARED_NAME and MV643XX_ETH_NAME
* Dropped un-necessary D-T irq fixup code


Ian Molton (7):
  Initial csb1724 board support (FDT)
  mv643xx.c: Remove magic numbers.
  mv643xx.c: Add basic device tree support.
  kirkwood: Add fixups for DT based mv643xx ethernet.
  csb1724: Enable device tree based mv643xx ethernet support.
  DT: Convert all kirkwood boards with mv643xx that use DT
  NET: mv643xx: remove device name macro.

 Documentation/devicetree/bindings/net/mv643xx.txt |   75 +++++++++++++++
 arch/arm/boot/dts/kirkwood-csb1724.dts            |   49 ++++++++++
 arch/arm/boot/dts/kirkwood-dnskw.dtsi             |    9 ++
 arch/arm/boot/dts/kirkwood-dreamplug.dts          |   18 ++++
 arch/arm/boot/dts/kirkwood-goflexnet.dts          |    8 ++
 arch/arm/boot/dts/kirkwood-ib62x0.dts             |   10 ++
 arch/arm/boot/dts/kirkwood-iconnect.dts           |   10 ++
 arch/arm/boot/dts/kirkwood-lsxl.dtsi              |   17 ++++
 arch/arm/boot/dts/kirkwood-ts219-6281.dts         |    8 +-
 arch/arm/boot/dts/kirkwood-ts219-6282.dts         |    8 +-
 arch/arm/boot/dts/kirkwood-ts219.dtsi             |    3 +
 arch/arm/boot/dts/kirkwood.dtsi                   |   33 +++++++
 arch/arm/mach-kirkwood/Kconfig                    |    7 ++
 arch/arm/mach-kirkwood/Makefile                   |    1 +
 arch/arm/mach-kirkwood/Makefile.boot              |    1 +
 arch/arm/mach-kirkwood/board-csb1724.c            |   60 ++++++++++++
 arch/arm/mach-kirkwood/board-dnskw.c              |    7 +-
 arch/arm/mach-kirkwood/board-dreamplug.c          |   13 +--
 arch/arm/mach-kirkwood/board-dt.c                 |   11 +++
 arch/arm/mach-kirkwood/board-goflexnet.c          |    7 +-
 arch/arm/mach-kirkwood/board-ib62x0.c             |    7 +-
 arch/arm/mach-kirkwood/board-iconnect.c           |    7 +-
 arch/arm/mach-kirkwood/board-lsxl.c               |   13 +--
 arch/arm/mach-kirkwood/board-ts219.c              |   10 +-
 arch/arm/mach-kirkwood/common.c                   |   26 +++++-
 arch/arm/mach-kirkwood/common.h                   |    9 ++
 arch/arm/plat-orion/common.c                      |   24 ++---
 arch/powerpc/platforms/chrp/pegasos_eth.c         |    4 +-
 arch/powerpc/sysdev/mv64x60_dev.c                 |    5 +-
 drivers/net/ethernet/marvell/mv643xx_eth.c        |  104 ++++++++++++++++++---
 include/linux/mv643xx_eth.h                       |    2 -
 31 files changed, 476 insertions(+), 90 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/mv643xx.txt
 create mode 100644 arch/arm/boot/dts/kirkwood-csb1724.dts
 create mode 100644 arch/arm/mach-kirkwood/board-csb1724.c

-- 
1.7.9.5
