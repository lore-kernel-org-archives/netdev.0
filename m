From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/11][pull request] Intel Wired LAN Driver Updates
Date: Fri,  7 Oct 2011 23:47:30 -0700
Message-ID: <1318056461-19562-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:59348 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751383Ab1JHGrn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Oct 2011 02:47:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains updates to igb only.  They are a
continuation of the cleanups and refactoring that Alex has done.
After this series there are 4-5 more patches to complete the work
that Alex has done on igb.

The following are changes since commit 1d0861acfb24d0ca0661ff5a156b992b2c589458:
  Add ethtool -g support to 8139cp
and are available in the git repository at
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next.git
or
  git://github.com/Jkirsher/net-next.git

Alexander Duyck (11):
  igb: push data into first igb_tx_buffer sooner to reduce stack usage
  igb: Use node specific allocations for the q_vectors and rings
  igb: avoid unnecessary conversions from u16 to int
  igb: Consolidate all of the ring feature flags into a single value
  igb: Move ITR related data into work container within the q_vector
  igb: cleanup IVAR configuration
  igb: retire the RX_CSUM flag and use the netdev flag instead
  igb: leave staterr in place and instead us a helper function to check
    bits
  igb: fix recent VLAN changes that would leave VLANs disabled after
    reset
  igb: move TX hang check flag into ring->flags
  igb: add support for NETIF_F_RXHASH

 drivers/net/ethernet/intel/igb/e1000_defines.h |    3 +
 drivers/net/ethernet/intel/igb/igb.h           |   53 ++-
 drivers/net/ethernet/intel/igb/igb_ethtool.c   |   14 +-
 drivers/net/ethernet/intel/igb/igb_main.c      |  675 +++++++++++++-----------
 4 files changed, 411 insertions(+), 334 deletions(-)

-- 
1.7.6.4
