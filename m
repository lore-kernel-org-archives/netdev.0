From: sunil.kovvuri@gmail.com
Subject: [PATCH v2 0/5] net: thunderx: Miscellaneous fixes
Date: Tue, 15 Nov 2016 17:35:56 +0530
Message-ID: <1479211562-14170-1-git-send-email-sunil.kovvuri@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        Sunil Goutham <sgoutham@cavium.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sunil Goutham <sgoutham@cavium.com>

This patchset includes fixes for incorrect LMAC credits,
unreliable driver statistics, memory leak upon interface
down e.t.c

Changes from v1:
- As suggested replaced bit shifting with BIT() macro
  in the patch 'Fix configuration of L3/L4 length checking'.

Radha Mohan Chintakuntla (1):
  net: thunderx: Introduce BGX_ID_MASK macro to extract bgx_id

Sunil Goutham (4):
  net: thunderx: Program LMAC credits based on MTU
  net: thunderx: Fix configuration of L3/L4 length checking
  net: thunderx: Fix VF driver's interface statistics
  net: thunderx: Fix memory leak and other issues upon interface toggle

 drivers/net/ethernet/cavium/thunder/nic.h          |  64 +++++----
 drivers/net/ethernet/cavium/thunder/nic_main.c     |  37 +++--
 drivers/net/ethernet/cavium/thunder/nic_reg.h      |   1 +
 .../net/ethernet/cavium/thunder/nicvf_ethtool.c    | 105 +++++++-------
 drivers/net/ethernet/cavium/thunder/nicvf_main.c   | 153 +++++++++++----------
 drivers/net/ethernet/cavium/thunder/nicvf_queues.c | 118 +++++++++-------
 drivers/net/ethernet/cavium/thunder/nicvf_queues.h |  24 +---
 drivers/net/ethernet/cavium/thunder/thunder_bgx.c  |   4 +-
 drivers/net/ethernet/cavium/thunder/thunder_bgx.h  |   2 +
 9 files changed, 274 insertions(+), 234 deletions(-)

-- 
2.7.4
