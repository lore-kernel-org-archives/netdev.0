From: Helmut Buchsbaum <helmut.buchsbaum@gmail.com>
Subject: [PATCH v2 0/6] Add support for MICREL KSZ8795CLX 5-port switch
Date: Mon,  8 Feb 2016 18:35:31 +0100
Message-ID: <1454952937-19428-1-git-send-email-helmut.buchsbaum@gmail.com>
Cc: netdev@vger.kernel.org,
	Helmut Buchsbaum <helmut.buchsbaum@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35671 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751197AbcBHRfv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2016 12:35:51 -0500
Received: by mail-wm0-f67.google.com with SMTP id g62so16493174wme.2
        for <netdev@vger.kernel.org>; Mon, 08 Feb 2016 09:35:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series refactors the spi-ks8995 driver to finally add support
for the MICREL KSZ8795CLX. Additionally support for controlling a GPIO
line for resetting the switch is added.

Helmut

Changes since v1:
 - removed initializing registers from Device Tree following Florian's
   advice
 - fixed GPIO handling for reset according to Andrew's remark.

Helmut Buchsbaum (6):
  net: phy: spi_ks8995: introduce spi_device_id table
  net: phy: spi_ks8995: verify chip and determine revision
  net: phy: spi_ks8995: add support for resetting switch using GPIO
  net: phy: spi_ks8995: generalize creation of SPI commands
  net: phy: spi_ks8995: add support for MICREL KSZ8795CLX
  dt-bindings: net: ks8995: add bindings documentation for ks8995

 .../devicetree/bindings/net/micrel-ks8995.txt      |  20 ++
 drivers/net/phy/spi_ks8995.c                       | 304 +++++++++++++++++----
 2 files changed, 265 insertions(+), 59 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/micrel-ks8995.txt

-- 
2.1.4
