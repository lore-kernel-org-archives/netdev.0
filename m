From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: [PATCH RFC 0/2] add Qualcomm QCA7000 ethernet driver
Date: Mon, 28 Apr 2014 19:54:55 +0200
Message-ID: <1398707697-43785-1-git-send-email-stefan.wahren@i2se.com>
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
To: davem@davemloft.net, robh+dt@kernel.org, pawel.moll@arm.org,
	mark.rutland@arm.org, ijc+devicetree@hellion.org.uk,
	galak@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.187]:57072 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755149AbaD1TnV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2014 15:43:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds support for the Qualcomm QCA7000 Homeplug GreenPHY.
The QCA7000 is serial-to-powerline bridge with two interfaces: UART and SPI.
These patches handles only the last one, with an Ethernet over SPI protocol
driver.

This driver based on the Qualcomm code [1], but contains a lot of changes
since last year:

* devictree support
* DebugFS support
* ethtool support
* better error handling
* performance improvements
* code cleanup

For more details look at our git repository [2].

The code has been tested only on Freescale i.MX28 boards, but should work
on other platforms.

Any comments about the code are welcome.

[1] - https://github.com/IoE/qca7000
[2] - https://github.com/I2SE/qca7000/tree/linux-mainline

Stefan Wahren (2):
  Documentation: add Device tree bindings for QCA7000
  net: qualcomm: new Ethernet over SPI driver for QCA7000

 .../devicetree/bindings/net/qca-qca7000-spi.txt    |   51 +
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/qualcomm/Kconfig              |   30 +
 drivers/net/ethernet/qualcomm/Makefile             |    6 +
 drivers/net/ethernet/qualcomm/qca_7k.c             |  149 +++
 drivers/net/ethernet/qualcomm/qca_7k.h             |   72 ++
 drivers/net/ethernet/qualcomm/qca_debug.c          |  231 +++++
 drivers/net/ethernet/qualcomm/qca_debug.h          |   32 +
 drivers/net/ethernet/qualcomm/qca_framing.c        |  155 +++
 drivers/net/ethernet/qualcomm/qca_framing.h        |  134 +++
 drivers/net/ethernet/qualcomm/qca_spi.c            | 1030 ++++++++++++++++++++
 drivers/net/ethernet/qualcomm/qca_spi.h            |  108 ++
 13 files changed, 2000 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/qca-qca7000-spi.txt
 create mode 100644 drivers/net/ethernet/qualcomm/Kconfig
 create mode 100644 drivers/net/ethernet/qualcomm/Makefile
 create mode 100644 drivers/net/ethernet/qualcomm/qca_7k.c
 create mode 100644 drivers/net/ethernet/qualcomm/qca_7k.h
 create mode 100644 drivers/net/ethernet/qualcomm/qca_debug.c
 create mode 100644 drivers/net/ethernet/qualcomm/qca_debug.h
 create mode 100644 drivers/net/ethernet/qualcomm/qca_framing.c
 create mode 100644 drivers/net/ethernet/qualcomm/qca_framing.h
 create mode 100644 drivers/net/ethernet/qualcomm/qca_spi.c
 create mode 100644 drivers/net/ethernet/qualcomm/qca_spi.h

-- 
1.7.10.4
