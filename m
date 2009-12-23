From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: [PATCH] can/netlink: add CAN_CTRLMODE_ONE_SHOT
Date: Wed, 23 Dec 2009 12:27:48 +0100
Message-ID: <1261567668-21692-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
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

This patch adds the flag CAN_CTRLMODE_ONE_SHOT. It is used as mask
or flag in the "struct can_ctrlmode".

It allows userspace via netlink to set a CAN controller into the special
"one-shot" mode. In this mode, if supported by the CAN controller, it
tries only once to deliver a CAN frame and aborts it if an error
(e.g.: arbitration lost) happens.

Signed-off-by: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Acked-by: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
---
 include/linux/can/netlink.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/linux/can/netlink.h b/include/linux/can/netlink.h
index 9ecbb78..c818335 100644
--- a/include/linux/can/netlink.h
+++ b/include/linux/can/netlink.h
@@ -80,6 +80,7 @@ struct can_ctrlmode {
 #define CAN_CTRLMODE_LOOPBACK	0x1	/* Loopback mode */
 #define CAN_CTRLMODE_LISTENONLY	0x2 	/* Listen-only mode */
 #define CAN_CTRLMODE_3_SAMPLES	0x4	/* Triple sampling mode */
+#define CAN_CTRLMODE_ONE_SHOT	0x8	/* One-Shot mode */
 
 /*
  * CAN device statistics
-- 
1.6.5.7
