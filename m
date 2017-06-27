From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH net-next 0/3] fix sw timestamping for non PTP packets
Date: Tue, 27 Jun 2017 16:58:50 +0300
Message-ID: <1498571933-3663-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: grygorii.strashko@ti.com, linux-omap@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: m-karicheri2@ti.com, w-kwok2@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series contains several corrections connected with timestamping
for cpsw and netcp drivers based on same cpts module.

Based on net/next

Ivan Khoronzhuk (3):
  net: ethernet: ti: cpsw: move skb timestamp to packet_submit
  net: ethernet: ti: cpsw: fix sw timestamping for non PTP packets
  net: ethernet: ti: netcp_ethss: use cpts to check if packet needs
    timestamping

 drivers/net/ethernet/ti/cpsw.c        |  6 +++---
 drivers/net/ethernet/ti/cpts.h        | 16 ++++++++++++++++
 drivers/net/ethernet/ti/netcp_ethss.c | 18 +-----------------
 3 files changed, 20 insertions(+), 20 deletions(-)

-- 
2.7.4
