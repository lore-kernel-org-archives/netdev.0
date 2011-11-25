From: Wolfgang Grandegger <wg@grandegger.com>
Subject: [PATCH net-next v2 0/4] can: cc770: add support for the Bosch CC770 and Intel AN82527
Date: Fri, 25 Nov 2011 10:43:20 +0100
Message-ID: <1322214204-1121-1-git-send-email-wg@grandegger.com>
Cc: linux-can@vger.kernel.org, socketcan-users@lists.berlios.de,
	IreneV <boir1@yandex.ru>,
	Stanislav Yelenskiy <stanislavelensky@yahoo.com>,
	Wolfgang Grandegger <wg@grandegger.com>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Already since a while we have support for the Bosch CC770 and Intel
AN82527 CAN controllers in our out-of-tree Socket-CAN repository.

In the meantime I found a TQM855L board with two AN82527 on it,
which allowed me to provide and test a generic platform driver
as well.

Changes since v1:

- remove version.h includes
- some minor corrections in the ISA bus driver
- add platform header file to the driver core
- add generic platform driver
- add and update device tree nodes for tqm8xx and tqm8548

It would be nice if somebody else could test the driver, especially
the ISA driver (I don't have hardware at hand).

Wolfgang.

Wolfgang Grandegger (4):
  can: cc770: add driver core for the Bosch CC770 and Intel AN82527
  can: cc770: add legacy ISA bus driver for the CC770 and AN82527
  can: cc770: add platform bus driver for the CC770 and AN82527
  powerpc: tqm8548/tqm8xx: add and update CAN device nodes

 .../devicetree/bindings/net/can/cc770.txt          |   56 ++
 arch/powerpc/boot/dts/tqm8548-bigflash.dts         |   19 +-
 arch/powerpc/boot/dts/tqm8548.dts                  |   19 +-
 arch/powerpc/boot/dts/tqm8xx.dts                   |   25 +
 drivers/net/can/Kconfig                            |    2 +
 drivers/net/can/Makefile                           |    1 +
 drivers/net/can/cc770/Kconfig                      |   21 +
 drivers/net/can/cc770/Makefile                     |    9 +
 drivers/net/can/cc770/cc770.c                      |  895 ++++++++++++++++++++
 drivers/net/can/cc770/cc770.h                      |  234 +++++
 drivers/net/can/cc770/cc770_isa.c                  |  336 ++++++++
 drivers/net/can/cc770/cc770_platform.c             |  289 +++++++
 include/linux/can/platform/cc770.h                 |   33 +
 13 files changed, 1929 insertions(+), 10 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/can/cc770.txt
 create mode 100644 drivers/net/can/cc770/Kconfig
 create mode 100644 drivers/net/can/cc770/Makefile
 create mode 100644 drivers/net/can/cc770/cc770.c
 create mode 100644 drivers/net/can/cc770/cc770.h
 create mode 100644 drivers/net/can/cc770/cc770_isa.c
 create mode 100644 drivers/net/can/cc770/cc770_platform.c
 create mode 100644 include/linux/can/platform/cc770.h

-- 
1.7.4.1

