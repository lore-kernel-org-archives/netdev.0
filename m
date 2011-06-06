From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: [PATCH 04/11] can: at91_can: let get_tx_* functions return unsigned
	int
Date: Mon,  6 Jun 2011 15:42:53 +0200
Message-ID: <1307367780-30715-5-git-send-email-mkl@pengutronix.de>
References: <1307367780-30715-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1307367780-30715-1-git-send-email-mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
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

Signed-off-by: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
---
 drivers/net/can/at91_can.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/can/at91_can.c b/drivers/net/can/at91_can.c
index 5358d70..716f22b 100644
--- a/drivers/net/can/at91_can.c
+++ b/drivers/net/can/at91_can.c
@@ -186,17 +186,17 @@ static struct can_bittiming_const at91_bittiming_const = {
 	.brp_inc	= 1,
 };
 
-static inline int get_tx_next_mb(const struct at91_priv *priv)
+static inline unsigned int get_tx_next_mb(const struct at91_priv *priv)
 {
 	return (priv->tx_next & AT91_NEXT_MB_MASK) + AT91_MB_TX_FIRST;
 }
 
-static inline int get_tx_next_prio(const struct at91_priv *priv)
+static inline unsigned int get_tx_next_prio(const struct at91_priv *priv)
 {
 	return (priv->tx_next >> AT91_NEXT_PRIO_SHIFT) & 0xf;
 }
 
-static inline int get_tx_echo_mb(const struct at91_priv *priv)
+static inline unsigned int get_tx_echo_mb(const struct at91_priv *priv)
 {
 	return (priv->tx_echo & AT91_NEXT_MB_MASK) + AT91_MB_TX_FIRST;
 }
-- 
1.7.4.1
