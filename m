From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH 0/3] net: ethernet: ti: cpsw: split driver data and per ndev data
Date: Fri,  5 Aug 2016 00:14:29 +0300
Message-ID: <1470345272-874-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: linux-omap@vger.kernel.org, grygorii.strashko@ti.com,
	linux-kernel@vger.kernel.org,
	Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: netdev@vger.kernel.org, mugunthanvnm@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In dual_emac mode the driver can handle 2 network devices. Each of them can use
its own private data and common data/resources. This patchset splits common driver
data/resources and private per net device data.

Doesn't have bad impact on performance.

Based on net-next/master

Ivan Khoronzhuk (3):
  net: ethernet: ti: cpsw: simplify submit routine
  net: ethernet: ti: cpsw: remove redundant check in napi poll
  net: ethernet: ti: cpsw: split common driver data and private net data

 drivers/net/ethernet/ti/cpsw.c | 797 +++++++++++++++++++----------------------
 1 file changed, 369 insertions(+), 428 deletions(-)

-- 
1.9.1
