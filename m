From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: [PATCH] net/can: activate bit-timing calculation
	and netlink based drivers by default
Date: Mon, 27 Jun 2011 09:39:51 +0200
Message-ID: <1309160391-22486-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, socketcan-users-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <socketcan-users-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-users>,
	<mailto:socketcan-users-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-users>
List-Post: <mailto:socketcan-users-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-users-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-users>,
	<mailto:socketcan-users-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-users-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-users-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

The two options "CAN bit-timing calculation" and
"Platform CAN drivers with Netlink support" have a "default Y". In order to
activate them by default, change to "default y".

Signed-off-by: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
---
 drivers/net/can/Kconfig |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
index bbf06f7..f1f9fd9 100644
--- a/drivers/net/can/Kconfig
+++ b/drivers/net/can/Kconfig
@@ -36,7 +36,7 @@ config CAN_SLCAN
 config CAN_DEV
 	tristate "Platform CAN drivers with Netlink support"
 	depends on CAN
-	default Y
+	default y
 	---help---
 	  Enables the common framework for platform CAN drivers with Netlink
 	  support. This is the standard library for CAN drivers.
@@ -45,7 +45,7 @@ config CAN_DEV
 config CAN_CALC_BITTIMING
 	bool "CAN bit-timing calculation"
 	depends on CAN_DEV
-	default Y
+	default y
 	---help---
 	  If enabled, CAN bit-timing parameters will be calculated for the
 	  bit-rate specified via Netlink argument "bitrate" when the device
-- 
1.7.4.1
