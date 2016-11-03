From: Johan Hovold <johan@kernel.org>
Subject: [PATCH net v2 0/4] net: fix device reference leaks
Date: Thu,  3 Nov 2016 18:40:18 +0100
Message-ID: <1478194822-29545-1-git-send-email-johan@kernel.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Johan Hovold <johan@kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Yisen Zhuang <yisen.zhuang@huawei.com>,
        Salil Mehta <salil.mehta@huawei.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series fixes a number of device reference leaks (and one of_node
leak) due to failure to drop the references taken by bus_find_device()
and friends.

Note that the final two patches have been compile tested only.

Thanks,
Johan


v2
 - hold reference to cpsw-phy-sel device while accessing private data as
   requested by David. Also update the commit message. (patch 1/4)
 - add linux-omap on CC where appropriate


Johan Hovold (4):
  phy: fix device reference leaks
  net: ethernet: ti: cpsw: fix device and of_node leaks
  net: ethernet: ti: davinci_emac: fix device reference leak
  net: hns: fix device reference leaks

 drivers/net/ethernet/hisilicon/hns/hnae.c |  8 +++++++-
 drivers/net/ethernet/ti/cpsw-phy-sel.c    |  3 +++
 drivers/net/ethernet/ti/davinci_emac.c    | 10 ++++++----
 drivers/net/phy/phy_device.c              |  2 ++
 4 files changed, 18 insertions(+), 5 deletions(-)

-- 
2.7.3
