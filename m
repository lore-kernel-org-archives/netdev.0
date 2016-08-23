From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] net: phy: xgmiitorgmii: Fix non static symbol warning
Date: Tue, 23 Aug 2016 15:06:05 +0000
Message-ID: <1471964765-32708-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Wei Yongjun <weiyongjun1@huawei.com>,
 linux-arm-kernel@lists.infradead.org
To: f.fainelli@gmail.com, michal.simek@xilinx.com, soren.brinkmann@xilinx.com
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

From: Wei Yongjun <weiyongjun1@huawei.com>

Fixes the following sparse warning:

drivers/net/phy/xilinx_gmii2rgmii.c:61:5: warning:
 symbol 'xgmiitorgmii_probe' was not declared. Should it be static?

Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 drivers/net/phy/xilinx_gmii2rgmii.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/xilinx_gmii2rgmii.c b/drivers/net/phy/xilinx_gmii2rgmii.c
index e7a20ec..2e408b8 100644
--- a/drivers/net/phy/xilinx_gmii2rgmii.c
+++ b/drivers/net/phy/xilinx_gmii2rgmii.c
@@ -58,7 +58,7 @@ static int xgmiitorgmii_read_status(struct phy_device *phydev)
 	return 0;
 }
 
-int xgmiitorgmii_probe(struct mdio_device *mdiodev)
+static int xgmiitorgmii_probe(struct mdio_device *mdiodev)
 {
 	struct device *dev = &mdiodev->dev;
 	struct device_node *np = dev->of_node, *phy_node;
