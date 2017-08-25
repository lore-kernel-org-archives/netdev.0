From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net v2 0/4] net: mvpp2: fix the mac address retrieval logic
Date: Fri, 25 Aug 2017 16:14:16 +0200
Message-ID: <20170825141420.14027-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>, andrew@lunn.ch,
        gregory.clement@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com, netdev@vger.kernel.org
To: davem@davemloft.net, thomas.petazzoni@free-electrons.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

The MAC address retrieval logic was broken and when using the PPv2
driver on PPv2.2 engines I ended up using the same mac address on all
ports. This series of patches fixes this, and also tackle a possible bug
when defining the mac address in the device tree.

Patch 1/4 can be applied to relevant stable trees (4.12+).

The series applies on net/master (9b4e946ce14e).

Thanks!
Antoine

Since v1:
  - Rebased onto net (was on net-next).

Antoine Tenart (4):
  net: mvpp2: fix the mac address used when using PPv2.2
  net: mvpp2: move the mac retrieval/copy logic into its own function
  net: mvpp2: fix use of the random mac address for PPv2.2
  net: mvpp2: fallback using h/w and random mac if the dt one isn't
    valid

 drivers/net/ethernet/marvell/mvpp2.c | 48 ++++++++++++++++++++++--------------
 1 file changed, 30 insertions(+), 18 deletions(-)

-- 
2.13.5
