From: sunil.kovvuri@gmail.com
Subject: [PATCH net 0/2] net: thunderx: Fixes for TSO offload issues
Date: Tue, 30 Aug 2016 11:36:25 +0530
Message-ID: <1472537187-21951-1-git-send-email-sunil.kovvuri@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        Sunil Goutham <sgoutham@cavium.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sunil Goutham <sgoutham@cavium.com>

This patch series fixes couple of issues w.r.t HW TSO offload

Sunil Goutham (2):
  net: thunderx: Fix for HW issue while padding TSO packet
  net: thunderx: Fix for issues with multiple CQEs posted for a TSO packet

 drivers/net/ethernet/cavium/thunder/nic.h          |  1 +
 drivers/net/ethernet/cavium/thunder/nic_main.c     | 11 +++-
 drivers/net/ethernet/cavium/thunder/nicvf_main.c   | 20 +++++--
 drivers/net/ethernet/cavium/thunder/nicvf_queues.c | 64 +++++++++++++++++++---
 4 files changed, 81 insertions(+), 15 deletions(-)

-- 
2.7.4
