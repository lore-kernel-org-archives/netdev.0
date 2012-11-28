From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/7][pull request] Intel Wired LAN Driver Updates
Date: Wed, 28 Nov 2012 05:06:11 -0800
Message-ID: <1354107978-24731-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:44342 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754843Ab2K1NGW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Nov 2012 08:06:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to igb, igbvf and ixgbe.

The following are changes since commit 03f52a0a554210d5049eeed9f1bb29047dc807cb:
  ip6mr: Add sizeof verification to MRT6_ASSERT and MT6_PIM
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Alexander Duyck (1):
  ixgbe: Drop RLPML configuration from x540 RXDCTL register
    configuration

Don Skidmore (1):
  ixgbe: bump version number

Greg Rose (1):
  ixgbe: Make the bridge mode setting sticky

Matthew Vick (1):
  igb: Use a 32-bit mask when calculating the flow control watermarks

Mitch A Williams (2):
  igbvf: work around i350 erratum
  igbvf: update version number

Neerav Parikh (1):
  ixgbe: Fix incorrect disabling of Tx hang check in case of PFC

 drivers/net/ethernet/intel/igb/igb_main.c      |  5 ++--
 drivers/net/ethernet/intel/igbvf/defines.h     |  1 +
 drivers/net/ethernet/intel/igbvf/igbvf.h       |  2 +-
 drivers/net/ethernet/intel/igbvf/netdev.c      | 17 +++++++++--
 drivers/net/ethernet/intel/ixgbe/ixgbe.h       |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  | 40 ++++++++++++--------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c |  1 +
 7 files changed, 39 insertions(+), 28 deletions(-)

-- 
1.7.11.7
