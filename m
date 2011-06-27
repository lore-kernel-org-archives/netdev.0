From: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
Subject: [PATCH] can: remove useless defaults in Kconfig
Date: Mon, 27 Jun 2011 17:00:13 +0200
Message-ID: <20110627150013.GB1874@e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

There's no need for "default N' (or 'default n') as it's default.

Signed-off-by: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
Acked-by: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
---
diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
index 1d699e3..ac48574 100644
--- a/drivers/net/can/Kconfig
+++ b/drivers/net/can/Kconfig
@@ -4,7 +4,6 @@ menu "CAN Device Drivers"
 config CAN_VCAN
 	tristate "Virtual Local CAN Interface (vcan)"
 	depends on CAN
-	default N
 	---help---
 	  Similar to the network loopback devices, vcan offers a
 	  virtual local CAN interface.
@@ -15,7 +14,6 @@ config CAN_VCAN
 config CAN_SLCAN
 	tristate "Serial / USB serial CAN Adaptors (slcan)"
 	depends on CAN
-	default N
 	---help---
 	  CAN driver for several 'low cost' CAN interfaces that are attached
 	  via serial lines or via USB-to-serial adapters using the LAWICEL
@@ -124,7 +122,6 @@ source "drivers/net/can/softing/Kconfig"
 config CAN_DEBUG_DEVICES
 	bool "CAN devices debugging messages"
 	depends on CAN
-	default N
 	---help---
 	  Say Y here if you want the CAN device drivers to produce a bunch of
 	  debug messages to the system log.  Select this if you are having
