From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/11][pull request] Intel Wired LAN Driver Updates
Date: Tue, 13 Nov 2012 06:03:14 -0800
Message-ID: <1352815405-751-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:8266 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754424Ab2KMOD2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2012 09:03:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbe, ixgbevf and igb.

The following are changes since commit 9fafd65ad407d4e0c96919a325f568dd95d032af:
  ipv6 ndisc: Use pre-defined in6addr_linklocal_allnodes.
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Akeem G. Abodunrin (2):
  igb: Support for modifying UDP RSS flow hashing
  igb: Ethtool support to enable and disable EEE

Alexander Duyck (4):
  ixgbe: Do not use DCA to prefetch the entire packet into the cache
  igb: Make TSO check for CHECKSUM_PARTIAL to avoid skb_is_gso check
  igb: Update igb Tx flags to improve code efficiency
  igb: Improve performance and reduce size of igb_tx_map

Carolyn Wyborny (1):
  igb: Clear Go Link Disconnect for 82580 and later devices

Emil Tantilov (1):
  ixgbevf: fix possible use of uninitialized variable

Greg Rose (2):
  ixgbevf: Add flag to indicate when rx is in net poll
  ixgbevf: Reduce size of maximum rx buffer

Jakub Kicinski (1):
  ixgbevf: make sure probe fails on MSI-X enable error

 drivers/net/ethernet/intel/igb/e1000_82575.c      |   8 +
 drivers/net/ethernet/intel/igb/e1000_defines.h    |   1 +
 drivers/net/ethernet/intel/igb/e1000_phy.h        |   1 +
 drivers/net/ethernet/intel/igb/igb.h              |  31 ++-
 drivers/net/ethernet/intel/igb/igb_ethtool.c      | 281 ++++++++++++++++++++++
 drivers/net/ethernet/intel/igb/igb_main.c         | 124 +++++-----
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |   1 -
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |   9 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |  54 +++--
 9 files changed, 412 insertions(+), 98 deletions(-)

-- 
1.7.11.7
