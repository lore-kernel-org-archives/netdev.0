From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/10][pull request] Intel Wired LAN Driver Update
Date: Mon, 29 Aug 2011 01:40:58 -0700
Message-ID: <1314607268-26958-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:36890 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753230Ab1H2IlN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Aug 2011 04:41:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains updates to ixgbe only.  Many are cleanup's
and fixes.

The following are changes since commit 7ac2ed0ceeafa130f85aa947b271b571c68b9e75:
  caif: Remove OOM messages, use kzalloc
and are available in the git repository at:
  master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net-next master

Alexander Duyck (2):
  ixgbe: Add support for setting CC bit when SR-IOV is enabled
  ixgbe: Always tag VLAN tagged packets

Don Skidmore (2):
  ixgbe: cleanup feature flags in ixgbe_probe
  ixgbe: fix ixgbe_fc_autoneg_fiber bug

Emil Tantilov (2):
  ixgbe: add check for supported modes
  ixgbe: clear RNBC only for 82598

John Fastabend (4):
  ixgbe: fixup remaining call sites for arbitrary TCs
  ixgbe: remove unneeded fdir pb alloc case
  ixgbe: consolidate, setup for multiple traffic classes
  ixgbe: PFC not cleared on X540 devices

 drivers/net/ethernet/intel/ixgbe/ixgbe.h           |    3 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c     |   87 --------------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c    |    9 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.c |    4 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c    |   46 +----------
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c   |   10 ++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |   53 +++++++++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h      |    1 +
 8 files changed, 63 insertions(+), 150 deletions(-)

-- 
1.7.6
