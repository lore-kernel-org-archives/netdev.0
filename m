From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net-next v3 0/3] net: mvpp2: improve the mac address retrieval logic
Date: Sat,  2 Sep 2017 11:06:46 +0200
Message-ID: <20170902090649.28426-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

This series aims at fixing the logic behind the MAC address retrieval in the
PPv2 driver. A possible issue is also fixed in patch 3/3 to introduce fallbacks
when the address given in the device tree isn't valid.

Thanks!
Antoine

Since v2:
  - Patch 1/4 from v2 was applied on net (and net was merged in net-next).
  - Rebased on net-next.

Since v1:
  - Rebased onto net (was on net-next).

Antoine Tenart (3):
  net: mvpp2: move the mac retrieval/copy logic into its own function
  net: mvpp2: fix use of the random mac address for PPv2.2
  net: mvpp2: fallback using h/w and random mac if the dt one isn't
    valid

 drivers/net/ethernet/marvell/mvpp2.c | 48 ++++++++++++++++++++++--------------
 1 file changed, 30 insertions(+), 18 deletions(-)

-- 
2.13.5
