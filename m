From: Varka Bhadram <varkabhadram@gmail.com>
Subject: [PATCH net-next v6 0/3] Driver for TI CC2520 Radio
Date: Fri, 20 Jun 2014 11:18:11 +0530
Message-ID: <1403243294-15400-1-git-send-email-varkab@cdac.in>
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, davem@davemloft.net,
	devicetree@vger.kernel.org, sowjanyap@cdac.in, venkatas@cdac.in,
	santoshk@cdac.in, Varka Bhadram <varkab@cdac.in>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:48025 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752058AbaFTFte (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2014 01:49:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds the driver support for TI cc2520 radio.
also devicetree bindings for the driver.

changes since v5:
	- added saddr and panc_changed functionality
	- rework on lqi field
	- improvements in checkings for reception
	- modification in debug messages

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
 drivers/net/ieee802154/cc2520.c                    | 1045 ++++++++++++++++++++
 include/linux/spi/cc2520.h                         |   26 +
 5 files changed, 1112 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/ieee802154/cc2520.txt
 create mode 100644 drivers/net/ieee802154/cc2520.c
 create mode 100644 include/linux/spi/cc2520.h

-- 
1.7.9.5
