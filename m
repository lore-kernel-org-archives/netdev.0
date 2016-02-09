From: Helmut Buchsbaum <helmut.buchsbaum@gmail.com>
Subject: [PATCH v3 0/6] Add support for MICREL KSZ8795CLX 5-port switch
Date: Tue,  9 Feb 2016 20:47:12 +0100
Message-ID: <1455047238-111358-1-git-send-email-helmut.buchsbaum@gmail.com>
Cc: netdev@vger.kernel.org,
	Helmut Buchsbaum <helmut.buchsbaum@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35827 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932145AbcBITre (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2016 14:47:34 -0500
Received: by mail-wm0-f65.google.com with SMTP id g62so5406546wme.2
        for <netdev@vger.kernel.org>; Tue, 09 Feb 2016 11:47:33 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series refactors the spi-ks8995 driver to finally add support
for the MICREL KSZ8795CLX. Additionally support for controlling a GPIO
line for resetting the switch is added.

Helmut

Changes since v2:
 - use GPIO_ACTIVE_LOW according to Andrew's remark.
 - use ePAPR compliant node name in example, thanks to Sergei for
   pointing out
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
