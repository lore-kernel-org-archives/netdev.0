From: Javier Martinez Canillas <javier@osg.samsung.com>
Subject: [PATCH 0/7] net: Fix module autoload for several platform drivers
Date: Mon, 17 Oct 2016 11:05:39 -0300
Message-ID: <1476713146-26632-1-git-send-email-javier@osg.samsung.com>
Cc: Javier Martinez Canillas <javier@osg.samsung.com>,
        Arnd Bergmann <arnd@arndb.de>,
        Timur Tabi <timur@codeaurora.org>,
        Noam Camus <noamca@mellanox.com>,
        Qianqian Xie <xieqianqian@huawei.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Lada Trimasova <Lada.Trimasova@synopsys.com>,
        Daode Huang <huangdaode@hisilicon.com>,
        Sebastian Frias <sf84@laposte.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Elad Kanfi <eladkan@mellanox.com>,
        Wei Yongjun <weiyongjun1@huawei.com>,
        Salil Mehta <salil.mehta@huawei.com>,
        Yisen Zhuang <yisen.zhuang@huawei.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Kejian Yan <yankejian@huawei.com>,
        Philippe Reynes <tremyfr@gmail.com>,
        =?UTF-8?q?M=C3=A5ns=20Rullg=C3=A5rd?= <mans@mansr.com>,
        netdev@vger.kernel.org, Gilad Ben-Yo
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello David,

I noticed that module autoload won't be working in a bunch of platform
drivers in the net subsystem and this patch series contains the fixes.

Best regards,
Javier


Javier Martinez Canillas (7):
  net: nps_enet: Fix module autoload
  net: ethernet: nb8800: Fix module autoload
  net: hns: Fix hns_dsaf module autoload for OF registration
  net: qcom/emac: Fix module autoload for OF registration
  net: hisilicon: Fix hns_mdio module autoload for OF registration
  net: dsa: b53: Fix module autoload
  net: dsa: bcm_sf2: Fix module autoload for OF registration

 drivers/net/dsa/b53/b53_mmap.c                     | 1 +
 drivers/net/dsa/bcm_sf2.c                          | 1 +
 drivers/net/ethernet/aurora/nb8800.c               | 1 +
 drivers/net/ethernet/ezchip/nps_enet.c             | 1 +
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c | 1 +
 drivers/net/ethernet/hisilicon/hns_mdio.c          | 1 +
 drivers/net/ethernet/qualcomm/emac/emac.c          | 1 +
 7 files changed, 7 insertions(+)

-- 
2.7.4
