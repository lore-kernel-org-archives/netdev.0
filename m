From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH v2 0/2] Part 1: handle addr_assign_type for
	random addresses
Date: Thu,  9 Feb 2012 20:48:52 +0100
Message-ID: <1328816934-11508-1-git-send-email-danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman@tuxdriver.com>, Jiri Pirko <jpirko@redhat.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-kernel@vger.kernel.org, Randy Dunlap <rdunlap@xenotime.net>,
	John Ronciak <john.ronciak@intel.com>, Danny Kukawka <dkukawka@suse.de>
To: "David S. Miller" <davem@davemloft.net>
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

This is an updated and split up version of my patch series to
fix the handling of addr_assign_type for random MAC addresses.

The first part contains the basic changes in etherdevice.h
and eth.c incl. needed adaptations in the existing code

Danny Kukawka (2):
  eth: reset addr_assign_type if eth_mac_addr() called
  rename dev_hw_addr_random and remove redundant second

 drivers/net/ethernet/intel/igbvf/netdev.c         |   11 +++++---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   28 ++++++++++++--------
 include/linux/etherdevice.h                       |   13 +++++----
 net/ethernet/eth.c                                |    2 +
 4 files changed, 33 insertions(+), 21 deletions(-)

-- 
1.7.7.3


------------------------------------------------------------------------------
Virtualization & Cloud Management Using Capacity Planning
Cloud computing makes use of virtualization - but cloud computing 
also focuses on allowing computing to be delivered as a service.
http://www.accelacomm.com/jaw/sfnl/114/51521223/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
