From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH 0/9] net: ethernet: ti: cpts: update and fixes
Date: Wed, 14 Sep 2016 16:02:22 +0300
Message-ID: <20160914130231.3035-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>, WingMan Kwok <w-kwok2@ti.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

It is preparation serie intended to clean up and optimize TI CPTS driver to
facilitate further integration with other TI's SoCs like Keystone 2.
It also include some non critical fixes:
 net: ethernet: ti: exclude cpts from build when disabled
 net: ethernet: ti: cpts: fix overflow check period
 net: ethernet: ti: cpts: clean up event list if event pool is empty


Grygorii Strashko (7):
  net: ethernet: ti: exclude cpts from build when disabled
  net: ethernet: ti: cpsw: minimize direct access to struct cpts
  net: ethernet: ti: cpts: rework initialization/deinitialization
  net: ethernet: ti: cpts: move dt props parsing to cpts driver
  net: ethernet: ti: cpts: calc mult and shift from refclk freq
  net: ethernet: ti: cpts: fix overflow check period
  net: ethernet: ti: cpts: switch to readl/writel_relaxed()

WingMan Kwok (2):
  net: ethernet: ti: cpts: add return value to tx and rx timestamp
    funcitons
  net: ethernet: ti: cpts: clean up event list if event pool is empty

 Documentation/devicetree/bindings/net/cpsw.txt |   4 +-
 drivers/net/ethernet/ti/Makefile               |   3 +-
 drivers/net/ethernet/ti/cpsw.c                 |  83 ++++----
 drivers/net/ethernet/ti/cpsw.h                 |   2 -
 drivers/net/ethernet/ti/cpts.c                 | 256 ++++++++++++++++++-------
 drivers/net/ethernet/ti/cpts.h                 |  93 +++++++--
 6 files changed, 319 insertions(+), 122 deletions(-)

-- 
2.9.3
