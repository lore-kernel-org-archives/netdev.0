From: Helmut Buchsbaum <helmut.buchsbaum@gmail.com>
Subject: [PATCH 0/7] Add support for MICREL KSZ8795CLX 5-port switch
Date: Sun,  7 Feb 2016 23:39:06 +0100
Message-ID: <1454884753-4560-1-git-send-email-helmut.buchsbaum@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
	Helmut Buchsbaum <helmut.buchsbaum@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36461 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752807AbcBGWjz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Feb 2016 17:39:55 -0500
Received: by mail-wm0-f65.google.com with SMTP id 128so12859997wmz.3
        for <netdev@vger.kernel.org>; Sun, 07 Feb 2016 14:39:54 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series refactors the spi-ks8995 driver to finally add support
for the MICREL KSZ8795CLX. Additionally support for setting initial
register values as well as controlling a GPIO line for resetting the
switch is added.

Helmut Buchsbaum (7):
  net: phy: spi_ks8995: introduce spi_device_id table
  net: phy: spi_ks8995: add chip verification and determine chip
    revision
  net: phy: spi_ks8995: add ability to configure register initialization
  net: phy: spi_ks8995: add support for resetting switch using GPIO
  net: phy: spi_ks8995: generalize creation of SPI commands
  net: phy: spi_ks8995: add support for MICREL KSZ8795CLX 5-Port managed
    switch
  dt-bindings: net: ks8995: add documentation for MICREL ks8995 driver

 .../devicetree/bindings/net/micrel-ks8995.txt      |  27 ++
 drivers/net/phy/spi_ks8995.c                       | 407 +++++++++++++++++----
 2 files changed, 371 insertions(+), 63 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/micrel-ks8995.txt

-- 
2.1.4
