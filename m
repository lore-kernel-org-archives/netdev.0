From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/6 v3][pull request] Intel Wired LAN Driver Updates
Date: Mon, 17 Oct 2011 17:12:42 -0700
Message-ID: <1318896767-5374-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:32924 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751293Ab1JRAMv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Oct 2011 20:12:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains updates to ixgbe, igbvf and igb.
This version of the series contains the following changes:

- igb fix/add check if subordinate VFs are assigned to VM's
- igbvf fix for trunk VLAN
- ixgbe 2 fixes for ethtool and 1 endianess fix

-v2 update the igb patch to resolve a variable initialization warning
-v3 Drop patch 5 (ixgbe: add hardware time stamping support)

The following are changes since commit fd38f734cb8200529e281338514945fcbff2364b:
  igbvf: convert to ndo_fix_features
and are available in the git repository at
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next.git

Emil Tantilov (3):
  ixgbe: fix endianess when writing driver version to firmware
  ixgbe: allow eeprom writes via ethtool
  ixgbe: change the eeprom version reported by ethtool

Greg Rose (2):
  igbvf: Fix trunk vlan
  igb: Check if subordinate VFs are assigned to virtual machines

 drivers/net/ethernet/intel/igb/igb.h             |    3 +
 drivers/net/ethernet/intel/igb/igb_main.c        |  177 ++++++++++++++++++----
 drivers/net/ethernet/intel/igbvf/netdev.c        |    4 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |    3 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c   |    2 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c  |   16 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |   84 ++++++++++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |    7 +-
 8 files changed, 246 insertions(+), 50 deletions(-)

-- 
1.7.6.4
