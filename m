From: Sunil Goutham <sunil.kovvuri@gmail.com>
Subject: [PATCH v2 0/5] net: thunderx: Miscellaneous fixes
Date: Wed,  2 Dec 2015 15:36:12 +0530
Message-ID: <1449050777-37836-1-git-send-email-sunil.kovvuri@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Sunil.Goutham@caviumnetworks.com,
	Sunil Goutham <sgoutham@cavium.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sunil Goutham <sgoutham@cavium.com>

This patch series contains fixes for various issues observed 
with BGX and NIC drivers.

Changes from v1:
- Fixed comment syle in the first patch of the series
- Removed 'Increase transmit queue length' patch from the series,
  will recheck if it's a driver or system issue and resubmit.

Sunil Goutham (3):
  net: thunderx: Set CQ timer threshold properly
  net: thunderx: Switchon carrier only upon interface link up
  net: thunderx: Enable BGX LMAC's RX/TX only after VF is up

Thanneeru Srinivasulu (2):
  net: thunderx: Force to load octeon-mdio before bgx driver.
  net: thunderx: Wait for delayed work to finish before destroying it

 drivers/net/ethernet/cavium/thunder/nic.h          |    5 +--
 drivers/net/ethernet/cavium/thunder/nic_main.c     |   23 ++++++++++++++--
 .../net/ethernet/cavium/thunder/nicvf_ethtool.c    |   16 ++++++++++-
 drivers/net/ethernet/cavium/thunder/nicvf_main.c   |    4 +--
 drivers/net/ethernet/cavium/thunder/nicvf_queues.c |    2 +-
 drivers/net/ethernet/cavium/thunder/nicvf_queues.h |    2 +-
 drivers/net/ethernet/cavium/thunder/thunder_bgx.c  |   28 +++++++++++++++++---
 drivers/net/ethernet/cavium/thunder/thunder_bgx.h  |    2 +
 8 files changed, 66 insertions(+), 16 deletions(-)
