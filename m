From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: (unknown)
Date: Thu, 17 Sep 2009 11:37:31 +0200
Message-ID: <1253180254-11910-1-git-send-email-mkl@pengutronix.de>
Cc: linux-arm-kernel@lists.infradead.org,
	Socketcan-core@lists.berlios.de,
	Andrew Victor <linux@maxim.org.za>, wg@grandegger.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:33856 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751726AbZIQJhr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2009 05:37:47 -0400
Subject: 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patch series adds support for the Atmel CAN controller as found
on the AT91SAM9263.

It adds the at91_can to the generic device definition, activates the CAN
controller on the at91sam9263ek and adds the driver itself.

Changes since V1:
- let Kconfig depend on CAN_DEV
- add example how driver is used in baord file

Please review and consider for inclusion.

cheers, Marc

Marc Kleine-Budde (3):
      at91sam9263: add at91_can device to generic device definition
      at91sam9263ek: activate at91 CAN controller
      at91_can: add driver for Atmel's CAN controller on AT91SAM9263

 arch/arm/mach-at91/at91sam9263_devices.c |   36 +
 arch/arm/mach-at91/board-sam9263ek.c     |   19 +
 arch/arm/mach-at91/include/mach/board.h  |    6 +
 drivers/net/can/Kconfig                  |    6 +
 drivers/net/can/Makefile                 |    1 +
 drivers/net/can/at91_can.c               | 1186 ++++++++++++++++++++++++++++++
 6 files changed, 1254 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/can/at91_can.c

