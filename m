From: Varka Bhadram <varkabhadram@gmail.com>
Subject: [PATCH net-next v5 0/3] Driver for TI CC2520 Radio
Date: Thu, 19 Jun 2014 14:08:47 +0530
Message-ID: <1403167131-22092-1-git-send-email-varkab@cdac.in>
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	sowjanyap@cdac.in, santoshk@cdac.in, venkatas@cdac.in,
	Varka Bhadram <varkab@cdac.in>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series adds the driver support for TI cc2520 radio.
also devicetree bindings for the driver.

changes since v4:
	- feature to write into cc2520 RAM
	- added h/w address filtering
	
changes since v3:
	- drop the unused varible

changes since v2:
	- drop spi mode dt binding

changes since v1:
	- improvement in gpio setup
	- changed len pointer to len variable

changes for v1:
	- improvements in the locking mechanism in Tx and SFD ISR
	- proper checkings for GPIO pins
	- avoids the memory leak for priv
	- used devm_* APIs
	- moved the code from header file to .c file
	- removed cc2520_unregister()

Varka Bhadram (3):
  ieee802154: cc2520: adds driver for TI CC2520 radio
  ieee802154: cc2520: add driver to kernel build system
  devicetree: add device tree bindings for cc2520 driver

 .../devicetree/bindings/net/ieee802154/cc2520.txt  |   29 +
 drivers/net/ieee802154/Kconfig                     |   11 +
 drivers/net/ieee802154/Makefile                    |    1 +
 drivers/net/ieee802154/cc2520.c                    | 1022 ++++++++++++++++++++
 include/linux/spi/cc2520.h                         |   26 +
 5 files changed, 1089 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/ieee802154/cc2520.txt
 create mode 100644 drivers/net/ieee802154/cc2520.c
 create mode 100644 include/linux/spi/cc2520.h

-- 
1.7.9.5
