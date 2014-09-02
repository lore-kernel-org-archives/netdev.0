From: Jean Sacren <sakiwit@gmail.com>
Subject: [PATCH net-next 0/6] Simplify Intel Wired LAN driver
	init/exit routine
Date: Tue,  2 Sep 2014 03:36:50 -0600
Message-ID: <1409650616-1035-1-git-send-email-sakiwit@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux.nics@intel.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
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

This series uses module_pci_driver() to simplify the init/exit
routine of some Intel Wired LAN drivers.

Jean Sacren (6):
  ixgb: remove the boilerplate of ixgb module for init/exit
  ixgbevf: remove the boilerplate of ixgbevf module for init/exit
  e100: remove the boilerplate of e100 module for init/exit
  igbvf: remove the boilerplate of igbvf module for init/exit
  e1000e: remove the boilerplate of e1000e module for init/exit
  i40evf: remove the boilerplate of i40evf module for init/exit

 drivers/net/ethernet/intel/e100.c                 | 22 ++++---------
 drivers/net/ethernet/intel/e1000e/netdev.c        | 35 +++-----------------
 drivers/net/ethernet/intel/i40evf/i40evf_main.c   | 37 +++------------------
 drivers/net/ethernet/intel/igbvf/netdev.c         | 35 +++-----------------
 drivers/net/ethernet/intel/ixgb/ixgb_main.c       | 39 +++--------------------
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 38 ++++------------------
 6 files changed, 32 insertions(+), 174 deletions(-)


------------------------------------------------------------------------------
Slashdot TV.  
Video for Nerds.  Stuff that matters.
http://tv.slashdot.org/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
