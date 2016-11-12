From: Colin King <colin.king@canonical.com>
Subject: [PATCH] net: ethernet: ixp4xx_eth: fix spelling mistake in debug message
Date: Sat, 12 Nov 2016 17:44:06 +0000
Message-ID: <20161112174406.8368-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: Krzysztof Halasa <khalasa@piap.pl>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

Trivial fix to spelling mistake "successed" to "succeeded"
in debug message.  Also unwrap multi-line literal string.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/xscale/ixp4xx_eth.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/xscale/ixp4xx_eth.c b/drivers/net/ethernet/xscale/ixp4xx_eth.c
index 46cc33b..07d862d 100644
--- a/drivers/net/ethernet/xscale/ixp4xx_eth.c
+++ b/drivers/net/ethernet/xscale/ixp4xx_eth.c
@@ -708,8 +708,7 @@ static int eth_poll(struct napi_struct *napi, int budget)
 			if (!qmgr_stat_below_low_watermark(rxq) &&
 			    napi_reschedule(napi)) { /* not empty again */
 #if DEBUG_RX
-				printk(KERN_DEBUG "%s: eth_poll"
-				       " napi_reschedule successed\n",
+				printk(KERN_DEBUG "%s: eth_poll napi_reschedule succeeded\n",
 				       dev->name);
 #endif
 				qmgr_disable_irq(rxq);
-- 
2.10.2
