From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/8][pull request] Intel Wired LAN Driver Updates
Date: Thu, 30 Aug 2012 22:16:06 -0700
Message-ID: <1346390174-30449-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:14908 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750975Ab2HaFQi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2012 01:16:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to e1000e and ixgbevf.

The following are changes since commit 761743ebc92df72053e736fce953a5d2e90099d5:
  net/fsl_pq_mdio: add support for the Fman 1G MDIO controller
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Alexander Duyck (2):
  ixgbevf: Add suspend and resume support to the VF
  ixgbevf: Cleanup handling of configuration for jumbo frames

Bruce Allan (6):
  e1000e: use correct type for read of 32-bit register
  e1000e: cleanup strict checkpatch MEMORY_BARRIER checks
  e1000e: cleanup strict checkpatch check
  e1000e: cleanup - remove inapplicable comment
  e1000e: cleanup - remove unnecessary variable
  e1000e: update driver version number

 drivers/net/ethernet/intel/e1000e/82571.c         |   4 +-
 drivers/net/ethernet/intel/e1000e/ethtool.c       |   3 +-
 drivers/net/ethernet/intel/e1000e/netdev.c        |  19 ++-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |   4 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 160 +++++++++++++++++-----
 drivers/net/ethernet/intel/ixgbevf/vf.c           |  14 ++
 drivers/net/ethernet/intel/ixgbevf/vf.h           |   1 +
 7 files changed, 164 insertions(+), 41 deletions(-)

-- 
1.7.11.4
