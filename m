From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH 0/5] cpsw: add per channel shaper configuration
Date: Tue, 29 Nov 2016 17:00:46 +0200
Message-ID: <1480431651-6081-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: linux-omap@vger.kernel.org,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        mugunthanvnm@ti.com, grygorii.strashko@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series is intended to allow user to set rate for per channel
shapers at cpdma level. This patchset doesn't have impact on performance.
The rate can be set with:

echo 100 > /sys/class/net/ethX/queues/tx-0/tx_maxrate

Tested on am572xx
Based on net-next/master

Ivan Khoronzhuk (5):
  net: ethernet: ti: davinci_cpdma: add weight function for channels
  net: ethernet: ti: davinci_cpdma: add set rate for a channel
  net: ethernet: ti: cpsw: add .ndo to set per-queue rate
  net: ethernet: ti: cpsw: optimize end of poll cycle
  net: ethernet: ti: cpsw: split tx budget according between channels

 drivers/net/ethernet/ti/cpsw.c          | 264 +++++++++++++++----
 drivers/net/ethernet/ti/davinci_cpdma.c | 453 ++++++++++++++++++++++++++++----
 drivers/net/ethernet/ti/davinci_cpdma.h |   6 +
 3 files changed, 624 insertions(+), 99 deletions(-)

-- 
2.7.4
