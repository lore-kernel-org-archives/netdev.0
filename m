From: Aleksey Makarov <aleksey.makarov@caviumnetworks.com>
Subject: [PATCH net 00/11] net: thunderx: Misc fixes
Date: Wed, 29 Jul 2015 16:49:35 +0300
Message-ID: <1438177787-20940-1-git-send-email-aleksey.makarov@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: David Daney <david.daney@cavium.com>,
 Sunil Goutham <Sunil.Goutham@caviumnetworks.com>,
 Aleksey Makarov <aleksey.makarov@caviumnetworks.com>,
 linux-kernel@vger.kernel.org,
 Robert Richter <robert.richter@caviumnetworks.com>,
 linux-arm-kernel@lists.infradead.org
To: <netdev@vger.kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Miscellaneous fixes for the ThunderX VNIC driver

All the patches can be applied individually.
It's ok to drop some if the maintainer feels uncomfortable
with applying for 4.2.

Sunil Goutham (10):
  net: thunderx: Fix data integrity issues with LDWB
  net: thunderx: Fix memory leak while tearing down interface
  net: thunderx: Fix RQ_DROP miscalculation
  net: thunderx: Fix memory leak when changing queue count
  net: thunderx: Fix TSO packet statistic
  net: thunderx: Suppress alloc_pages() failure warnings
  net: thunderx: Wakeup TXQ only if CQE_TX are processed
  net: thunderx: Set watchdog timeout value
  net: thunderx: Fix crash when changing rss with mutliple traffic flows
  net: thunderx: Add PCI driver shutdown routine

Thanneeru Srinivasulu (1):
  net: thunderx: Fix for crash while BGX teardown

 drivers/net/ethernet/cavium/thunder/nic.h          | 12 ++++-
 .../net/ethernet/cavium/thunder/nicvf_ethtool.c    | 26 ++++++----
 drivers/net/ethernet/cavium/thunder/nicvf_main.c   | 55 +++++++++++++++-------
 drivers/net/ethernet/cavium/thunder/nicvf_queues.c | 17 ++++---
 drivers/net/ethernet/cavium/thunder/nicvf_queues.h | 14 ++++--
 drivers/net/ethernet/cavium/thunder/thunder_bgx.c  |  5 +-
 6 files changed, 92 insertions(+), 37 deletions(-)

-- 
2.4.6
