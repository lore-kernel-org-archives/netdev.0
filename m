From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: [PATCH 01/11] can: at91_can: don't align struct definitions
Date: Mon,  6 Jun 2011 15:42:50 +0200
Message-ID: <1307367780-30715-2-git-send-email-mkl@pengutronix.de>
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
 drivers/net/can/at91_can.c |   34 +++++++++++++++++-----------------
 1 files changed, 17 insertions(+), 17 deletions(-)

diff --git a/drivers/net/can/at91_can.c b/drivers/net/can/at91_can.c
index 74efb5a..8f15ae4 100644
--- a/drivers/net/can/at91_can.c
+++ b/drivers/net/can/at91_can.c
@@ -157,21 +157,21 @@ enum at91_mb_mode {
 #define AT91_IRQ_ALL		(0x1fffffff)
 
 struct at91_priv {
-	struct can_priv		can;	   /* must be the first member! */
-	struct net_device	*dev;
-	struct napi_struct	napi;
+	struct can_priv can;		/* must be the first member! */
+	struct net_device *dev;
+	struct napi_struct napi;
 
-	void __iomem		*reg_base;
+	void __iomem *reg_base;
 
-	u32			reg_sr;
-	unsigned int		tx_next;
-	unsigned int		tx_echo;
-	unsigned int		rx_next;
+	u32 reg_sr;
+	unsigned int tx_next;
+	unsigned int tx_echo;
+	unsigned int rx_next;
 
-	struct clk		*clk;
-	struct at91_can_data	*pdata;
+	struct clk *clk;
+	struct at91_can_data *pdata;
 
-	canid_t			mb0_id;
+	canid_t mb0_id;
 };
 
 static struct can_bittiming_const at91_bittiming_const = {
@@ -271,7 +271,7 @@ static void at91_setup_mailboxes(struct net_device *dev)
 
 	/* reset acceptance mask and id register */
 	for (i = AT91_MB_RX_FIRST; i <= AT91_MB_RX_LAST; i++) {
-		at91_write(priv, AT91_MAM(i), 0x0 );
+		at91_write(priv, AT91_MAM(i), 0x0);
 		at91_write(priv, AT91_MID(i), AT91_MID_MIDE);
 	}
 
@@ -1231,11 +1231,11 @@ static int __devexit at91_can_remove(struct platform_device *pdev)
 }
 
 static struct platform_driver at91_can_driver = {
-	.probe		= at91_can_probe,
-	.remove		= __devexit_p(at91_can_remove),
-	.driver		= {
-		.name	= KBUILD_MODNAME,
-		.owner	= THIS_MODULE,
+	.probe = at91_can_probe,
+	.remove = __devexit_p(at91_can_remove),
+	.driver = {
+		.name = KBUILD_MODNAME,
+		.owner = THIS_MODULE,
 	},
 };
 
-- 
1.7.4.1
