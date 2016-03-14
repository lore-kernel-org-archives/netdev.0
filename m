From: sunil.kovvuri@gmail.com
Subject: [PATCH v2 0/2] net: thunderx: Performance enhancement changes
Date: Mon, 14 Mar 2016 16:36:13 +0530
Message-ID: <1457953578-7054-1-git-send-email-sunil.kovvuri@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	davem@davemloft.net, sgoutham@cavium.com,
	robert.richter@caviumnetworks.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sunil Goutham <sgoutham@cavium.com>

Below patches attempts to improve performance by reducing
no of atomic operations while allocating new receive buffers
and reducing cache misses by adjusting nicvf structure elements.

Changes from v1:
 No changes, resubmitting a fresh as per David's suggestion.

Sunil Goutham (2):
  net: thunderx: Set recevie buffer page usage count in bulk
  net: thunderx: Adjust nicvf structure to reduce cache misses

 drivers/net/ethernet/cavium/thunder/nic.h          |   51 ++++++++++++--------
 drivers/net/ethernet/cavium/thunder/nicvf_queues.c |   31 +++++++++---
 2 files changed, 53 insertions(+), 29 deletions(-)
