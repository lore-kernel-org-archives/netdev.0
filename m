From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: [PATCH 0/3] at91_can: add support for Atmel's CAN controller on
	AT91SAM9263
Date: Wed, 16 Sep 2009 11:46:42 +0200
Message-ID: <1253094405-3216-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch series add support for Atmels's CAN controller as found
on the AT91SAM9263.

Marc Kleine-Budde (3):
      at91sam9263: add at91_can device to generic device definition
      at91sam9263ek: activate at91 CAN controller
      at91_can: add driver for Atmel's CAN controller on AT91SAM9263

 arch/arm/mach-at91/at91sam9263_devices.c |   36 +
 arch/arm/mach-at91/board-sam9263ek.c     |   19 +
 arch/arm/mach-at91/include/mach/board.h  |    6 +
 drivers/net/can/Kconfig                  |    6 +
 drivers/net/can/Makefile                 |    1 +
 drivers/net/can/at91_can.c               | 1177 ++++++++++++++++++++++++++++++
 6 files changed, 1245 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/can/at91_can.c
