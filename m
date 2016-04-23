From: Michael Heimpold <mhei@heimpold.de>
Subject: [PATCH net-next 0/2] net: ethernet: enc28j60: small improvements
Date: Sat, 23 Apr 2016 23:43:18 +0200
Message-ID: <1461447800-11381-1-git-send-email-mhei@heimpold.de>
Cc: Michael Heimpold <mhei@heimpold.de>
To: Jonathan Cameron <jic23@kernel.org>,
	"Andrew F . Davis" <afd@ti.com>, Mark Brown <broonie@kernel.org>,
	netdev@vger.kernel.org,
	Claudio Lanconelli <lanconelli.claudio@eptar.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.216]:27156 "EHLO
	mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752351AbcDWVoH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Apr 2016 17:44:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series of two patches adds the following improvements to the driver:

1) Rework the central SPI read function so that it is compatible with
   SPI masters which only support half duplex transfers.

2) Add a device tree binding for the driver.

Michael Heimpold (2):
  net: ethernet: enc28j60: support half-duplex SPI controllers
  net: ethernet: enc28j60: add device tree support

 .../devicetree/bindings/net/microchip-enc28j60.txt | 49 ++++++++++++++++++++++
 drivers/net/ethernet/microchip/enc28j60.c          | 27 +++++++++---
 2 files changed, 70 insertions(+), 6 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/microchip-enc28j60.txt

-- 
2.5.0
