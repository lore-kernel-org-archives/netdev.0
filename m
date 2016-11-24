From: sunil.kovvuri@gmail.com
Subject: [PATCH 0/4] net: thunderx: Support for 80xx, RED, PFC e.t.c
Date: Thu, 24 Nov 2016 14:47:59 +0530
Message-ID: <1479979083-15963-1-git-send-email-sunil.kovvuri@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        Sunil Goutham <sgoutham@cavium.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sunil Goutham <sgoutham@cavium.com>

This patch series adds support for SLM modules present on 80xx
silicon, enables ramdom early discard, backpressure generation,
PFC and some ethtool changes to display supported link modes e.t.c.

Sunil Goutham (3):
  net: thunderx: 80xx BGX0 configuration changes
  net: thunderx: Configure RED and backpressure levels
  net: thunderx: Pause frame support

Thanneeru Srinivasulu (1):
  net: thunderx: Add ethtool support for supported ports and link modes.

 drivers/net/ethernet/cavium/thunder/nic.h          | 19 +++++
 drivers/net/ethernet/cavium/thunder/nic_main.c     | 37 +++++++++
 .../net/ethernet/cavium/thunder/nicvf_ethtool.c    | 87 +++++++++++++++++++++-
 drivers/net/ethernet/cavium/thunder/nicvf_main.c   |  7 ++
 drivers/net/ethernet/cavium/thunder/nicvf_queues.c |  9 ++-
 drivers/net/ethernet/cavium/thunder/nicvf_queues.h | 24 ++++--
 drivers/net/ethernet/cavium/thunder/q_struct.h     |  8 +-
 drivers/net/ethernet/cavium/thunder/thunder_bgx.c  | 74 +++++++++++++++++-
 drivers/net/ethernet/cavium/thunder/thunder_bgx.h  | 12 +++
 9 files changed, 262 insertions(+), 15 deletions(-)

-- 
2.7.4
