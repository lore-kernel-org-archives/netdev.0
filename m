From: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
Subject: Re: [PATCH] net/can: activate bit-timing
 calculation and netlink based drivers by default
Date: Mon, 27 Jun 2011 15:50:44 +0200
Message-ID: <20110627135044.GF318@e-circ.dyndns.org>
References: <1309160391-22486-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, socketcan-users-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org
To: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Return-path: <socketcan-users-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1309160391-22486-1-git-send-email-mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
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

Is this modification then also the right thing to do?

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
