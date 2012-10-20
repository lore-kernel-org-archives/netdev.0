From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/13][pull request] Intel Wired LAN Driver Updates
Date: Fri, 19 Oct 2012 23:25:54 -0700
Message-ID: <1350714367-24208-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:53579 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752598Ab2JTG0R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Oct 2012 02:26:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbe only.

The following are changes since commit 72ec301a27badb11635b08dc845101815abcf4a7:
  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Alexander Duyck (7):
  ixgbe: Add support for IPv6 and UDP to ixgbe_get_headlen
  ixgbe: Add support for tracking the default user priority to SR-IOV
  ixgbe: Add support for GET_QUEUES message to get DCB configuration
  ixgbe: Enable support for VF API version 1.1 in the PF.
  ixgbevf: Add VF DCB + SR-IOV support
  ixgbe: Drop unnecessary addition from ixgbe_set_rx_buffer_len
  ixgbe: Fix possible memory leak in ixgbe_set_ringparam

Don Skidmore (2):
  ixgbe: Add function ixgbe_reset_pipeline_82599
  ixgbe: Add support for pipeline reset

Emil Tantilov (1):
  ixgbe: add WOL support for new subdevice id

Jacob Keller (1):
  ixgbe: (PTP) refactor init, cyclecounter and reset

Tushar Dave (1):
  ixgbe: Correcting small packet padding

Wei Yongjun (1):
  ixgbe: using is_zero_ether_addr() to simplify the code

 drivers/net/ethernet/intel/ixgbe/ixgbe.h          |   7 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c    | 149 ++++++++++++++++----
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c   |  73 +++++++++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h   |   1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c  | 102 +++++++-------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |  66 +++++++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h      |  10 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c      | 109 +++++++--------
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c    | 124 +++++++++++++----
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h     |   1 +
 drivers/net/ethernet/intel/ixgbevf/defines.h      |   7 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |   4 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 159 +++++++++++++++++++++-
 drivers/net/ethernet/intel/ixgbevf/mbx.h          |  10 ++
 drivers/net/ethernet/intel/ixgbevf/vf.c           |  58 ++++++++
 drivers/net/ethernet/intel/ixgbevf/vf.h           |   2 +
 16 files changed, 688 insertions(+), 194 deletions(-)

-- 
1.7.11.7
