From: sunil.kovvuri@gmail.com
Subject: [PATCH 0/9] net: thunderx: Adds XDP support
Date: Tue,  2 May 2017 18:36:49 +0530
Message-ID: <1493730418-24606-1-git-send-email-sunil.kovvuri@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        Sunil Goutham <sgoutham@cavium.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sunil Goutham <sgoutham@cavium.com>

This patch series adds support for XDP to ThunderX NIC driver
which is used on CN88xx, CN81xx and CN83xx platforms. 

Patches 1-4 are performance improvement and cleanup patches
which are done keeping XDP performance bottlenecks in view.
Rest of the patches adds actual XDP support.

Sunil Goutham (9):
  net: thunderx: Support for page recycling
  net: thunderx: Optimize RBDR descriptor handling
  net: thunderx: Optimize CQE_TX handling
  net: thunderx: Cleanup receive buffer allocation
  net: thunderx: Add basic XDP support
  net: thunderx: Add support for XDP_DROP
  net: thunderx: Add support for XDP_TX
  net: thunderx: Support for XDP header adjustment
  net: thunderx: Optimize page recycling for XDP

 drivers/net/ethernet/cavium/thunder/nic.h          |  10 +-
 .../net/ethernet/cavium/thunder/nicvf_ethtool.c    |  29 +-
 drivers/net/ethernet/cavium/thunder/nicvf_main.c   | 313 +++++++++++++++--
 drivers/net/ethernet/cavium/thunder/nicvf_queues.c | 387 +++++++++++++++++----
 drivers/net/ethernet/cavium/thunder/nicvf_queues.h |  32 +-
 drivers/net/ethernet/cavium/thunder/q_struct.h     |  10 +-
 6 files changed, 657 insertions(+), 124 deletions(-)

-- 
2.7.4
