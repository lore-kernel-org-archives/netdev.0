From: Sunil Goutham <sunil.kovvuri@gmail.com>
Subject: [PATCH 00/13] net: thunderx: HW TSO support and other fixes
Date: Mon, 30 Nov 2015 23:48:56 +0530
Message-ID: <1448907549-5296-1-git-send-email-sunil.kovvuri@gmail.com>
References: <y>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Sunil.Goutham@caviumnetworks.com,
	Sunil Goutham <sgoutham@cavium.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <y>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sunil Goutham <sgoutham@cavium.com>

This patch series contains fixes for various issues and support for 
HW TSO which is added in pass2 silicon.

Sunil Goutham (9):
  net: thunderx: Increase transmit queue length
  net: thunderx: Set CQ timer threshold properly
  net: thunderx: Switchon carrier only upon interface link up
  net: thunderx: Remove unnecessary rcv buffer start address management
  net: thunderx: Enable BGX LMAC's RX/TX only after VF is up
  net: thunderx: HW TSO support for pass2 chips
  net: thunderx: Enable CQE count threshold interrupt for pass2 chip
  net: thunderx: HW errata workaround for non-tunneled TSO pkts
  net: thunderx: Fix for duplicate CQEs by HW for TSO packets

Thanneeru Srinivasulu (3):
  net: thunderx: Force to load octeon-mdio before bgx driver.
  net: thunderx: Wait for delayed work to finish before destroying it
  net: thunderx: Add TX timeout, RX buff allocation fail to driver
    stats.

Yury Norov (1):
  net: thunderx: nicvf_queues: nivc_*_intr: remove duplication

 drivers/net/ethernet/cavium/thunder/nic.h          |   22 ++-
 drivers/net/ethernet/cavium/thunder/nic_main.c     |   34 ++-
 drivers/net/ethernet/cavium/thunder/nicvf_ethtool.c    |   18 ++-
 drivers/net/ethernet/cavium/thunder/nicvf_main.c   |   20 ++-
 drivers/net/ethernet/cavium/thunder/nicvf_queues.c |  219 +++++++-------------
 drivers/net/ethernet/cavium/thunder/nicvf_queues.h |   19 +-
 drivers/net/ethernet/cavium/thunder/q_struct.h     |   30 ++--
 drivers/net/ethernet/cavium/thunder/thunder_bgx.c  |   28 +++-
 drivers/net/ethernet/cavium/thunder/thunder_bgx.h  |    2 +
 9 files changed, 189 insertions(+), 203 deletions(-)
