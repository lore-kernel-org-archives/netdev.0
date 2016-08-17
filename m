From: Colin King <colin.king@canonical.com>
Subject: [PATCH] net: ethernet: nuvoton: fix spelling mistake: "aligment" ->
 "alignment"
Date: Wed, 17 Aug 2016 18:31:35 +0100
Message-ID: <1471455095-129910-1-git-send-email-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: Wan ZongShun <mcuos.com@gmail.com>, linux-arm-kernel@lists.infradead.org,
 netdev@vger.kernel.org
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

From: Colin Ian King <colin.king@canonical.com>

trivial fix to spelling mistake in dev_err message

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/nuvoton/w90p910_ether.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/nuvoton/w90p910_ether.c b/drivers/net/ethernet/nuvoton/w90p910_ether.c
index 87b7b81..712d8bc 100644
--- a/drivers/net/ethernet/nuvoton/w90p910_ether.c
+++ b/drivers/net/ethernet/nuvoton/w90p910_ether.c
@@ -751,7 +751,7 @@ static void netdev_rx(struct net_device *dev)
 				dev_err(&pdev->dev, "rx crc err\n");
 				ether->stats.rx_crc_errors++;
 			} else if (status & RXDS_ALIE) {
-				dev_err(&pdev->dev, "rx aligment err\n");
+				dev_err(&pdev->dev, "rx alignment err\n");
 				ether->stats.rx_frame_errors++;
 			} else if (status & RXDS_PTLE) {
 				dev_err(&pdev->dev, "rx longer err\n");
-- 
2.9.3
