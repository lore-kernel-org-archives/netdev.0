From: Govindarajulu Varadarajan <govindarajulu90@gmail.com>
Subject: [PATCH net-next 0/5] driver/net: enic: enic driver updates
Date: Wed,  4 Sep 2013 11:17:13 +0530
Message-ID: <1378273638-7780-1-git-send-email-govindarajulu90@gmail.com>
Cc: benve@cisco.com, ssujith@cisco.com, nistrive@cisco.com,
	umalhi@cisco.com,
	Govindarajulu Varadarajan <govindarajulu90@gmail.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series includes support for multi-tx, rss_hash, RPS, RFS, DMA64, 
export symbols for cisco low latency driver and update the driver version and 
driver maintainers.

Govindarajulu Varadarajan (5):
  driver/net: enic: Add multi tx support for enic
  driver/net: enic: record q_number and rss_hash for skb
  driver/net: enic: Try DMA 64 first, then failover to DMA
  driver/net: enic: Exposing symbols for Cisco's low latency driver
  driver/net: enic: update enic maintainers and driver

 MAINTAINERS                                 |  3 +-
 drivers/net/ethernet/cisco/enic/enic.h      |  4 +--
 drivers/net/ethernet/cisco/enic/enic_main.c | 55 ++++++++++++++++++++---------
 drivers/net/ethernet/cisco/enic/vnic_dev.c  | 10 ++++++
 drivers/net/ethernet/cisco/enic/vnic_dev.h  |  1 +
 5 files changed, 54 insertions(+), 19 deletions(-)

-- 
1.8.4
