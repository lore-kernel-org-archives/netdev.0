From: sunil.kovvuri@gmail.com
Subject: [PATCH v2 0/2] BQL support and fix for a regression issue
Date: Fri, 23 Sep 2016 14:42:26 +0530
Message-ID: <1474621948-9172-1-git-send-email-sunil.kovvuri@gmail.com>
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

Changes from v1:
- As suggested added 'Fixes' tag with commit id of previous commit 
  which cuased issue.
- Also fixed the missing netdev_tx_reset_queue() function call in 
  byte queue limits support patch.

Sunil Goutham (2):
  net: thunderx: Fix issue with IRQ namimg
  net: thunderx: Support for byte queue limits

 drivers/net/ethernet/cavium/thunder/nic.h          |  2 +-
 drivers/net/ethernet/cavium/thunder/nicvf_main.c   | 14 ++++++++--
 drivers/net/ethernet/cavium/thunder/nicvf_queues.c | 30 ++++++++++++++--------
 3 files changed, 33 insertions(+), 13 deletions(-)

-- 
2.7.4
