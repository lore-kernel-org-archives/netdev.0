From: John Crispin <john@phrozen.org>
Subject: [PATCH 00/12] net: mediatek: various small fixes
Date: Sun,  5 Jun 2016 08:32:53 +0200
Message-ID: <1465108385-38286-1-git-send-email-john@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Felix Fietkau <nbd@nbd.name>, Sean Wang <keyhaede@gmail.com>,
	netdev@vger.kernel.org, linux-mediatek@lists.infradead.org,
	linux-kernel@vger.kernel.org, John Crispin <john@phrozen.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series contains various small fixes that we stumbled across while
doing thorough testing and code level reviewing of the driver. The only
patch that sticks out is the first one, which addresses a DQL related
issue. The rest are just minor fixes.

John Crispin (12):
  net: mediatek: fix DQL support
  net: mediatek: add missing return code check
  net: mediatek: fix missing free of scratch memory
  net: mediatek: invalid buffer lookup in mtk_tx_map()
  net: mediatek: dropped rx packets are not being counted properly
  net: mediatek: add next data pointer coherency protection
  net: mediatek: disable all interrupts during probe
  net: mediatek: fix threshold value
  net: mediatek: increase watchdog_timeo
  net: mediatek: fix off by one in the TX ring allocation
  net: mediatek: only wake the queue if it is stopped
  net: mediatek: remove superfluous queue wake up call

 drivers/net/ethernet/mediatek/mtk_eth_soc.c |   94 ++++++++++++++++++---------
 drivers/net/ethernet/mediatek/mtk_eth_soc.h |    3 +
 2 files changed, 65 insertions(+), 32 deletions(-)

-- 
1.7.10.4
