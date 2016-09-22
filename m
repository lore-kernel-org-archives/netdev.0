From: sunil.kovvuri@gmail.com
Subject: [PATCH 0/2] BQL support and fix for a regression issue
Date: Thu, 22 Sep 2016 14:35:19 +0530
Message-ID: <1474535121-13958-1-git-send-email-sunil.kovvuri@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        Sunil Goutham <sgoutham@cavium.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sunil Goutham <sgoutham@cavium.com>

These patches add byte queue limit support and also fixes a regression
issue introduced by commit
'net: thunderx: Use netdev's name for naming VF's interrupts'

Sunil Goutham (2):
  net: thunderx: Fix issue with IRQ namimg
  net: thunderx: Support for byte queue limits

 drivers/net/ethernet/cavium/thunder/nic.h          |  2 +-
 drivers/net/ethernet/cavium/thunder/nicvf_main.c   | 11 ++++++--
 drivers/net/ethernet/cavium/thunder/nicvf_queues.c | 30 ++++++++++++++--------
 3 files changed, 30 insertions(+), 13 deletions(-)

-- 
2.7.4
