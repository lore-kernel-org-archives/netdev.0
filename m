From: Michael Heimpold <mhei@heimpold.de>
Subject: [PATCH v3 net-next 0/2] net: ethernet: enc28j60: small improvements
Date: Thu, 28 Apr 2016 22:06:13 +0200
Message-ID: <1461873975-6368-1-git-send-email-mhei@heimpold.de>
Cc: Michael Heimpold <mhei@heimpold.de>
To: Jonathan Cameron <jic23@kernel.org>,
	"Andrew F . Davis" <afd@ti.com>, Mark Brown <broonie@kernel.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.216]:26417 "EHLO
	mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753021AbcD1UGe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 16:06:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series of two patches adds the following improvements to the driver:

1) Rework the central SPI read function so that it is compatible with
   SPI masters which only support half duplex transfers.

2) Add a device tree binding for the driver.

Changelog:

v3: * renamed and improved binding documentation as
      suggested by Rob Herring

v2: * took care of Arnd Bergmann's review comments
      - allow to specify MAC address via DT
      - unconditionally define DT id table
    * increased the driver version minor number
    * driver author's email address bounces, removed from address list

v1: * Initial submission

Michael Heimpold (2):
  net: ethernet: enc28j60: support half-duplex SPI controllers
  net: ethernet: enc28j60: add device tree support

 .../devicetree/bindings/net/microchip,enc28j60.txt | 59 ++++++++++++++++++++++
 drivers/net/ethernet/microchip/enc28j60.c          | 34 ++++++++++---
 2 files changed, 85 insertions(+), 8 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/microchip,enc28j60.txt

-- 
2.5.0
