From: Aleksey Makarov <aleksey.makarov@auriga.com>
Subject: [PATCH net-next v2 0/8] net: thunderx: New features and fixes
Date: Sun, 30 Aug 2015 12:29:08 +0300
Message-ID: <1440926958-1874-1-git-send-email-aleksey.makarov@auriga.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	David Daney <david.daney@cavium.com>,
	Robert Richter <robert.richter@caviumnetworks.com>,
	Aleksey Makarov <aleksey.makarov@auriga.com>,
	Sunil Goutham <Sunil.Goutham@caviumnetworks.com>,
	Alexey Klimov <klimov.linux@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

v2:
  - The unused affinity_mask field of the structure cmp_queue 
  has been deleted. (thanks to David Miller)
  - The unneeded initializers have been dropped. (thanks to Alexey Klimov)
  - The commit message "net: thunderx: Rework interrupt handling"
  has been fixed. (thanks to Alexey Klimov)

Aleksey Makarov (1):
  net: thunderx: fix MAINTAINERS

Sunil Goutham (7):
  net: thunderx: Add receive error stats reporting via ethtool
  net: thunderx: mailboxes: remove code duplication
  net: thunderx: Receive hashing HW offload support
  net: thunderx: Support for HW VLAN stripping
  net: thunderx: Rework interrupt handling
  net: thunderx: Support for upto 96 queues for a VF
  net: thunderx: Support for internal loopback mode

 MAINTAINERS                                        |   3 +-
 drivers/net/ethernet/cavium/thunder/nic.h          |  93 +++-
 drivers/net/ethernet/cavium/thunder/nic_main.c     | 198 +++++++-
 .../net/ethernet/cavium/thunder/nicvf_ethtool.c    | 182 +++++--
 drivers/net/ethernet/cavium/thunder/nicvf_main.c   | 541 +++++++++++++++------
 drivers/net/ethernet/cavium/thunder/nicvf_queues.c | 144 +++---
 drivers/net/ethernet/cavium/thunder/nicvf_queues.h |  44 +-
 drivers/net/ethernet/cavium/thunder/thunder_bgx.c  |  31 ++
 drivers/net/ethernet/cavium/thunder/thunder_bgx.h  |   4 +
 9 files changed, 911 insertions(+), 329 deletions(-)

-- 
2.5.0
