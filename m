From: weiyj_lk@163.com
Subject: [PATCH -next] net: mediatek: fix non static symbol warnings
Date: Tue, 12 Jul 2016 11:36:44 +0000
Message-ID: <1468323404-2193-1-git-send-email-weiyj_lk@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Wei Yongjun <yongjun_wei@trendmicro.com.cn>,
 linux-mediatek@lists.infradead.org, linux-arm-kernel@lists.infradead.org
To: Felix Fietkau <nbd@openwrt.org>, John Crispin <blogic@openwrt.org>,
 Matthias Brugger <matthias.bgg@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Fixes the following sparse warnings:

drivers/net/ethernet/mediatek/mtk_eth_soc.c:79:5: warning:
 symbol '_mtk_mdio_write' was not declared. Should it be static?
drivers/net/ethernet/mediatek/mtk_eth_soc.c:98:5: warning:
 symbol '_mtk_mdio_read' was not declared. Should it be static?

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 682797e..6f597eb 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -76,8 +76,8 @@ static int mtk_mdio_busy_wait(struct mtk_eth *eth)
 	return -1;
 }
 
-u32 _mtk_mdio_write(struct mtk_eth *eth, u32 phy_addr,
-		    u32 phy_register, u32 write_data)
+static u32 _mtk_mdio_write(struct mtk_eth *eth, u32 phy_addr,
+			   u32 phy_register, u32 write_data)
 {
 	if (mtk_mdio_busy_wait(eth))
 		return -1;
@@ -95,7 +95,7 @@ u32 _mtk_mdio_write(struct mtk_eth *eth, u32 phy_addr,
 	return 0;
 }
 
-u32 _mtk_mdio_read(struct mtk_eth *eth, int phy_addr, int phy_reg)
+static u32 _mtk_mdio_read(struct mtk_eth *eth, int phy_addr, int phy_reg)
 {
 	u32 d;
