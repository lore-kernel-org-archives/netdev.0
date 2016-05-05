From: John Crispin <john@phrozen.org>
Subject: [PATCH 00/12] net-next: mediatek: bug fixes and tx stall fixes
Date: Thu,  5 May 2016 11:26:13 +0200
Message-ID: <1462440385-51939-1-git-send-email-john@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: nbd@nbd.name, netdev@vger.kernel.org,
	linux-mediatek@lists.infradead.org, linux-kernel@vger.kernel.org,
	John Crispin <john@phrozen.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series is a collection of fixes for bugs that we stumble across while
doing more performance testing and code level review.

John Crispin (12):
  net-next: mediatek: fix DQL support
  net-next: mediatek: add missing return code check
  net-next: mediatek: fix missing free of scratch memory
  net-next: mediatek: invalid buffer lookup in mtk_tx_map()
  net-next: mediatek: dropped rx packets are not being counted properly
  net-next: mediatek: add next data pointer coherency protection
  net-next: mediatek: disable all interrupts during probe
  net-next: mediatek: fix threshold value
  net-next: mediatek: increase watchdog_timeo
  net-next: mediatek: fix off by one in the TX ring allocation
  net-next: mediatek: only wake the queue if it is stopped
  net-next: mediatek: remove superfluous queue wake up call

 drivers/net/ethernet/mediatek/mtk_eth_soc.c |   94 ++++++++++++++++++---------
 drivers/net/ethernet/mediatek/mtk_eth_soc.h |    3 +
 2 files changed, 65 insertions(+), 32 deletions(-)

-- 
1.7.10.4
