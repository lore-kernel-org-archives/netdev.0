From: Sunil Goutham <sunil.kovvuri@gmail.com>
Subject: [PATCH 0/6] net: thunderx: Miscellaneous fixes
Date: Tue,  1 Dec 2015 14:43:37 +0530
Message-ID: <1448961223-41888-1-git-send-email-sunil.kovvuri@gmail.com>
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

This patch series contains fixes for various issues observed 
with BGX and NIC drivers.

Sunil Goutham (4):
  net: thunderx: Increase transmit queue length
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
 drivers/net/ethernet/cavium/thunder/nicvf_queues.h |    6 ++--
 drivers/net/ethernet/cavium/thunder/thunder_bgx.c  |   28 +++++++++++++++++---
 drivers/net/ethernet/cavium/thunder/thunder_bgx.h  |    2 +
 8 files changed, 68 insertions(+), 18 deletions(-)
