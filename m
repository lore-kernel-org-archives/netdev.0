From: Joachim Eastwood <manabian-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next 13/17] stmmac: dwmac-rk: make rk_gmac_ops structs
 static const
Date: Wed, 29 Jul 2015 00:09:00 +0200
Message-ID: <1438121344-5304-14-git-send-email-manabian@gmail.com>
References: <1438121344-5304-1-git-send-email-manabian@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Joachim Eastwood <manabian-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
 linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: peppe.cavallaro-qxv4g6HH51o@public.gmane.org, heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org, roger.chen-TNX95d0MmH7DzftRWevZcw@public.gmane.org,
 davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1438121344-5304-1-git-send-email-manabian-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-rockchip>,
 <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-rockchip/>
List-Post: <mailto:linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-rockchip>,
 <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-rockchip" <linux-rockchip-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

Mark the rk_gmac_ops structures as static const as they should be.

Signed-off-by: Joachim Eastwood <manabian-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
index 65c1e1afe6a8..5d8042ea8370 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
@@ -46,7 +46,7 @@ struct rk_priv_data {
 	struct platform_device *pdev;
 	int phy_iface;
 	struct regulator *regulator;
-	struct rk_gmac_ops *ops;
+	const struct rk_gmac_ops *ops;
 
 	bool clk_enabled;
 	bool clock_input;
@@ -177,7 +177,7 @@ static void rk3288_set_rmii_speed(struct rk_priv_data *bsp_priv, int speed)
 	}
 }
 
-struct rk_gmac_ops rk3288_ops = {
+static const struct rk_gmac_ops rk3288_ops = {
 	.set_to_rgmii = rk3288_set_to_rgmii,
 	.set_to_rmii = rk3288_set_to_rmii,
 	.set_rgmii_speed = rk3288_set_rgmii_speed,
@@ -289,7 +289,7 @@ static void rk3368_set_rmii_speed(struct rk_priv_data *bsp_priv, int speed)
 	}
 }
 
-struct rk_gmac_ops rk3368_ops = {
+static const struct rk_gmac_ops rk3368_ops = {
 	.set_to_rgmii = rk3368_set_to_rgmii,
 	.set_to_rmii = rk3368_set_to_rmii,
 	.set_rgmii_speed = rk3368_set_rgmii_speed,
@@ -448,7 +448,7 @@ static int phy_power_on(struct rk_priv_data *bsp_priv, bool enable)
 }
 
 static struct rk_priv_data *rk_gmac_setup(struct platform_device *pdev,
-					  struct rk_gmac_ops *ops)
+					  const struct rk_gmac_ops *ops)
 {
 	struct rk_priv_data *bsp_priv;
 	struct device *dev = &pdev->dev;
-- 
1.8.0
