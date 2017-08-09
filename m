From: John Crispin <john@phrozen.org>
Subject: [PATCH 0/2] net-next: mediatek: bring up QDMA RX ring 0
Date: Wed,  9 Aug 2017 12:09:30 +0200
Message-ID: <20170809100932.10539-1-john@phrozen.org>
Cc: netdev@vger.kernel.org, linux-mediatek@lists.infradead.org,
        linux-kernel@vger.kernel.org, Muciri Gatimu <muciri@openmesh.com>,
        Shashidhar Lakkavalli <shashidhar.lakkavalli@openmesh.com>,
        John Crispin <john@phrozen.org>
To: "David S . Miller" <davem@davemloft.net>,
        Sean Wang <sean.wang@mediatek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The MT7623 has several DMA rings. Inside the SW path, the core will use
the PDMA when receiving traffic. While bringing up the HW path we noticed
that the PPE requires the QDMA RX to also be brought up as it uses this
ring internally for its flow scheduling.

John Crispin (2):
  net-next: mediatek: fix typos inside the header file
  net-next: mediatek: bring up QDMA RX ring 0

 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 36 +++++++++++++++++++++--------
 drivers/net/ethernet/mediatek/mtk_eth_soc.h |  7 ++++--
 2 files changed, 31 insertions(+), 12 deletions(-)

-- 
2.11.0
