From: Johan Hovold <johan@kernel.org>
Subject: [PATCH net 0/7] net: cpsw: fix leaks and probe deferral
Date: Wed, 16 Nov 2016 15:35:09 +0100
Message-ID: <1479306916-27673-1-git-send-email-johan@kernel.org>
Cc: Grygorii Strashko <grygorii.strashko@ti.com>,
        linux-omap@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Johan Hovold <johan@kernel.org>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series fixes as number of leaks and issues in the cpsw probe-error
and driver-unbind paths, some which specifically prevented deferred
probing.

Johan


Johan Hovold (7):
  net: ethernet: ti: cpsw: fix bad register access in probe error path
  net: ethernet: ti: cpsw: fix mdio device reference leak
  net: ethernet: ti: cpsw: fix deferred probe
  net: ethernet: ti: cpsw: fix of_node and phydev leaks
  net: ethernet: ti: cpsw: fix secondary-emac probe error path
  net: ethernet: ti: cpsw: add missing sanity check
  net: ethernet: ti: cpsw: fix fixed-link phy probe deferral

 drivers/net/ethernet/ti/cpsw.c | 88 ++++++++++++++++++++++++++++++++++--------
 1 file changed, 71 insertions(+), 17 deletions(-)

-- 
2.7.3
