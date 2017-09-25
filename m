From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net v2 0/3] net: mvpp2: various fixes
Date: Mon, 25 Sep 2017 14:59:45 +0200
Message-ID: <20170925125948.13507-1-antoine.tenart@free-electrons.com>
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

This series contains 3 fixes for the Marvell PPv2 driver.

Thanks!
Antoine

Since v1:
  - Removed one patch about dma masks as it would need a better fix.
  - Added one fix about the MAC Tx clock source selection.

Antoine Tenart (1):
  net: mvpp2: do not select the internal source clock

Stefan Chulski (1):
  net: mvpp2: fix parsing fragmentation detection

Yan Markman (1):
  net: mvpp2: fix port list indexing

 drivers/net/ethernet/marvell/mvpp2.c | 31 ++++++++++++++++++++-----------
 1 file changed, 20 insertions(+), 11 deletions(-)

-- 
2.13.5
