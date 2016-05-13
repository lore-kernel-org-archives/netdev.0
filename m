From: Jisheng Zhang <jszhang@marvell.com>
Subject: [PATCH 0/2] net: pxa168_eth: improve performance
Date: Fri, 13 May 2016 19:57:28 +0800
Message-ID: <1463140650-7038-1-git-send-email-jszhang@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	Jisheng Zhang <jszhang@marvell.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series is to improve the pxa168_eth driver performance by using
{readl|writel}_relaxed or appropriate memory barriers.

Jisheng Zhang (2):
  net: pxa168_eth: use {readl|writel}_relaxed instead of readl/writel
  net: pxa168_eth: Use dma_wmb/rmb where appropriate

 drivers/net/ethernet/marvell/pxa168_eth.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

-- 
2.8.1
