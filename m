From: Mark Einon <mark.einon@gmail.com>
Subject: [PATCH 3/4] staging: et131x: Remove unnecessary OOM message
Date: Wed, 24 Sep 2014 09:54:41 +0100
Message-ID: <1411548882-10639-3-git-send-email-mark.einon@gmail.com>
References: <1411506437.29268.13.camel@joe-AO725>
 <1411548882-10639-1-git-send-email-mark.einon@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, angus@agibson.me, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, joe@perches.com,
 Mark Einon <mark.einon@gmail.com>, davem@davemloft.net
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1411548882-10639-1-git-send-email-mark.einon@gmail.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

Reported-by: Joe Perches <joe@perches.com>
Signed-off-by: Mark Einon <mark.einon@gmail.com>
---
 drivers/staging/et131x/et131x.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/staging/et131x/et131x.c b/drivers/staging/et131x/et131x.c
index f5459ec..cd90831 100644
--- a/drivers/staging/et131x/et131x.c
+++ b/drivers/staging/et131x/et131x.c
@@ -2418,10 +2418,8 @@ static struct rfd *nic_rx_pkts(struct et131x_adapter *adapter)
 	rfd->len = len;
 
 	skb = dev_alloc_skb(rfd->len + 2);
-	if (!skb) {
-		dev_err(&adapter->pdev->dev, "Couldn't alloc an SKB for Rx\n");
+	if (!skb)
 		return NULL;
-	}
 
 	adapter->netdev->stats.rx_bytes += rfd->len;
 
-- 
1.7.10.4
