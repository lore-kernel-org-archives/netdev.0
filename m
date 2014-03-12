From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 0/9] drivers/net: Convert uses of
	__constant_<foo> to <foo>
Date: Wed, 12 Mar 2014 10:22:29 -0700
Message-ID: <cover.1394644825.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, linux-usb@vger.kernel.org,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	ath9k-devel@lists.ath9k.org, linux-arm-kernel@lists.infradead.org
To: netdev@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Joe Perches (9):
  brocade: Convert uses of __constant_<foo> to <foo>
  e100: Convert uses of __constant_<foo> to <foo>
  igb: Convert uses of __constant_<foo> to <foo>
  igbvf: Convert uses of __constant_<foo> to <foo>
  ixgbe: Convert uses of __constant_<foo> to <foo>
  ixgbevf: Convert uses of __constant_<foo> to <foo>
  xilinx: Convert uses of __constant_<foo> to <foo>
  lg-vl600: Convert uses of __constant_<foo> to <foo>
  ath9k: Convert uses of __constant_<foo> to <foo>

 drivers/net/ethernet/brocade/bna/bnad.c           | 16 +++++-------
 drivers/net/ethernet/intel/e100.c                 |  4 +--
 drivers/net/ethernet/intel/igb/igb_main.c         | 12 ++++-----
 drivers/net/ethernet/intel/igbvf/netdev.c         |  4 +--
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c     |  8 +++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     | 30 +++++++++++------------
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |  4 +--
 drivers/net/ethernet/xilinx/ll_temac_main.c       |  4 +--
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c |  2 +-
 drivers/net/usb/lg-vl600.c                        |  2 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c    |  4 +--
 11 files changed, 43 insertions(+), 47 deletions(-)

-- 
1.8.1.2.459.gbcd45b4.dirty


------------------------------------------------------------------------------
Learn Graph Databases - Download FREE O'Reilly Book
"Graph Databases" is the definitive new guide to graph databases and their
applications. Written by three acclaimed leaders in the field,
this first edition is now available. Download your free book today!
http://p.sf.net/sfu/13534_NeoTech
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
