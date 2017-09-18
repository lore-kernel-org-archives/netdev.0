From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net 0/3] net: mvpp2: various fixes
Date: Mon, 18 Sep 2017 15:04:05 +0200
Message-ID: <20170918130408.23114-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com,
        miquel.raynal@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

This series contains various fixes for the Marvell PPv2 driver. Please
have a thorough look at patch 1/3 ("net: mvpp2: fix the dma_mask and
coherent_dma_mask settings for PPv2.2") as I'm not 100% sure about the
fix implementation.

Thanks!
Antoine

Antoine Tenart (1):
  net: mvpp2: fix the dma_mask and coherent_dma_mask settings for PPv2.2

Stefan Chulski (1):
  net: mvpp2: fix parsing fragmentation detection

Yan Markman (1):
  net: mvpp2: fix port list indexing

 drivers/net/ethernet/marvell/mvpp2.c | 44 ++++++++++++++++++++++++++++--------
 1 file changed, 35 insertions(+), 9 deletions(-)

-- 
2.13.5
