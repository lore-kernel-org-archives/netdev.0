From: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>
Subject: [Patch v5 0/2] net: ethernet: xilinx: mac addr and mips
Date: Fri, 2 Sep 2016 12:39:24 +0100
Message-ID: <1472816366-1018-1-git-send-email-Zubair.Kakakhel@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
        <Zubair.Kakakhel@imgtec.com>
To: <davem@davemloft.net>, <michal.simek@xilinx.com>,
        <soren.brinkmann@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

A couple of simple patches to generate the random mac address
if none is found. And enabling the driver for mips.

Based on v4.8-rc4.

These were part of a larger series but that series is growing
wildly. Splitting and submitting the net subsystem patches separately.
Hence the v5.

Regards,
ZubairLK

Zubair Lutfullah Kakakhel (2):
  net: ethernet: xilinx: Generate random mac if none found
  net: ethernet: xilinx: Enable emaclite for MIPS

 drivers/net/ethernet/xilinx/Kconfig           | 4 ++--
 drivers/net/ethernet/xilinx/xilinx_emaclite.c | 8 +++++---
 2 files changed, 7 insertions(+), 5 deletions(-)

-- 
1.9.1
