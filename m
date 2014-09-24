From: Mark Einon <mark.einon@gmail.com>
Subject: [PATCH 4/4] staging: et131x: Remove unnecessary parentheses
Date: Wed, 24 Sep 2014 09:54:42 +0100
Message-ID: <1411548882-10639-4-git-send-email-mark.einon@gmail.com>
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
 drivers/staging/et131x/et131x.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/et131x/et131x.c b/drivers/staging/et131x/et131x.c
index cd90831..0a927d2 100644
--- a/drivers/staging/et131x/et131x.c
+++ b/drivers/staging/et131x/et131x.c
@@ -2634,7 +2634,7 @@ static int nic_send_packet(struct et131x_adapter *adapter, struct tcb *tcb)
 				desc[frag].len_vlan = skb_headlen(skb) / 2;
 				dma_addr = dma_map_single(&adapter->pdev->dev,
 							  skb->data,
-							  (skb_headlen(skb) / 2),
+							  skb_headlen(skb) / 2,
 							  DMA_TO_DEVICE);
 				desc[frag].addr_lo = lower_32_bits(dma_addr);
 				desc[frag].addr_hi = upper_32_bits(dma_addr);
@@ -2643,8 +2643,8 @@ static int nic_send_packet(struct et131x_adapter *adapter, struct tcb *tcb)
 				desc[frag].len_vlan = skb_headlen(skb) / 2;
 				dma_addr = dma_map_single(&adapter->pdev->dev,
 							  skb->data +
-							  (skb_headlen(skb) / 2),
-							  (skb_headlen(skb) / 2),
+							  skb_headlen(skb) / 2,
+							  skb_headlen(skb) / 2,
 							  DMA_TO_DEVICE);
 				desc[frag].addr_lo = lower_32_bits(dma_addr);
 				desc[frag].addr_hi = upper_32_bits(dma_addr);
-- 
1.7.10.4
