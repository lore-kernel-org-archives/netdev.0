From: Wolfram Sang <w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: [PATCH 05/11] net/can/mscan: fix function annotations
Date: Mon, 16 Nov 2009 23:57:48 +0100
Message-ID: <1258412274-14686-6-git-send-email-w.sang@pengutronix.de>
References: <1258412274-14686-1-git-send-email-w.sang@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	linuxppc-dev-mnsaURCQ41sdnm+yROfE0A@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1258412274-14686-1-git-send-email-w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
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

- use extern where apropriate
- don't export symbols

Signed-off-by: Wolfram Sang <w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
---
 drivers/net/can/mscan/mscan.c |    3 ---
 drivers/net/can/mscan/mscan.h |    2 +-
 2 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/drivers/net/can/mscan/mscan.c b/drivers/net/can/mscan/mscan.c
index ca8b556..76e413e 100644
--- a/drivers/net/can/mscan/mscan.c
+++ b/drivers/net/can/mscan/mscan.c
@@ -611,7 +611,6 @@ int register_mscandev(struct net_device *dev, int clock_src)
 
 	return register_candev(dev);
 }
-EXPORT_SYMBOL_GPL(register_mscandev);
 
 void unregister_mscandev(struct net_device *dev)
 {
@@ -621,7 +620,6 @@ void unregister_mscandev(struct net_device *dev)
 	clrbits8(&regs->canctl1, MSCAN_CANE);
 	unregister_candev(dev);
 }
-EXPORT_SYMBOL_GPL(unregister_mscandev);
 
 struct net_device *alloc_mscandev(void)
 {
@@ -651,7 +649,6 @@ struct net_device *alloc_mscandev(void)
 
 	return dev;
 }
-EXPORT_SYMBOL_GPL(alloc_mscandev);
 
 MODULE_AUTHOR("Andrey Volkov <avolkov-ppI4tVfbJvJWk0Htik3J/w@public.gmane.org>");
 MODULE_LICENSE("GPL v2");
diff --git a/drivers/net/can/mscan/mscan.h b/drivers/net/can/mscan/mscan.h
index 76a8abf..2018000 100644
--- a/drivers/net/can/mscan/mscan.h
+++ b/drivers/net/can/mscan/mscan.h
@@ -279,7 +279,7 @@ struct mscan_priv {
 	struct napi_struct napi;
 };
 
-struct net_device *alloc_mscandev(void);
+extern struct net_device *alloc_mscandev(void);
 /*
  * clock_src:
  *	1 = The MSCAN clock source is the onchip Bus Clock.
-- 
1.6.3.3
