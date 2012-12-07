From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/5][pull request] Intel Wired LAN Driver Updates
Date: Thu,  6 Dec 2012 22:11:30 -0800
Message-ID: <1354860695-27039-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:4860 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751756Ab2LGGLo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Dec 2012 01:11:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to igb and ixgbe.

The following are changes since commit b93196dc5af7729ff7cc50d3d322ab1a364aa14f:
  net: fix some compiler warning in net/core/neighbour.c
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Carolyn Wyborny (1):
  igb: Update igb version to 4.1.2

Jacob Keller (1):
  ixgbe: check whether thermal sensor is enabled.

Joe Perches (1):
  ixgbe: Use is_valid_ether_addr

Stefan Assmann (2):
  igb: remove duplicate code for fallback interrupt initialization
  igb: release already assigned MSI-X interrupts if setup fails

 drivers/net/ethernet/intel/igb/igb_main.c       | 55 ++++++++++++++-----------
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c  |  2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c | 26 +-----------
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h |  1 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   |  7 +++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h   | 11 +----
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c   |  2 +-
 7 files changed, 42 insertions(+), 62 deletions(-)

-- 
1.7.11.7
