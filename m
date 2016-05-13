From: Jisheng Zhang <jszhang@marvell.com>
Subject: [PATCH 0/2] net: mv643xx_eth: improve performance
Date: Fri, 13 May 2016 19:59:18 +0800
Message-ID: <1463140760-7128-1-git-send-email-jszhang@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jisheng Zhang <jszhang@marvell.com>, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: <sebastian.hesselbarth@gmail.com>, <davem@davemloft.net>
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

This series is to improve the mv643xx_eth driver performance by using
{readl|writel}_relaxed or appropriate memory barriers.

Since I have no mv643xx_eth platforms, tests are appreciated!

Jisheng Zhang (2):
  net: mv643xx_eth: use {readl|writel}_relaxed instead of readl/writel
  net: mv643xx_eth: use dma_wmb/rmb where appropriate

 drivers/net/ethernet/marvell/mv643xx_eth.c | 43 +++++++++++++++---------------
 1 file changed, 22 insertions(+), 21 deletions(-)

-- 
2.8.1
