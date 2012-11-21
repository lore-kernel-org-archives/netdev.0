From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/10][pull request] Intel Wired LAN Driver Updates
Date: Wed, 21 Nov 2012 02:47:26 -0800
Message-ID: <1353494856-12344-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:28698 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753385Ab2KUKrj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Nov 2012 05:47:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbe and igb.

The following are changes since commit de4594a51c904ddcd6c3a6cdd100f7c1d94d3239:
  sctp: send abort chunk when max_retrans exceeded
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Alexander Duyck (1):
  igb: Do not parse past IP header on fragments beyond the first

Jacob Keller (3):
  ixgbe: use ETQF filter name instead of magic number
  ixgbe: remove needless queuing for L4 ptp packets
  ixgbe: ethtool correctly identify autoneg setting

John Fastabend (1):
  ixgbe: fdb: only allow NUD_PERM fdb entries

Josh Hay (2):
  ixgbe: Reformat output of ixgbe_dump
  ixgbe: eliminate Smatch warnings in ixgbe_debugfs.c

Matthew Vick (2):
  igb: Update PTP Rx filters
  igb: No longer rely on APME to determine WoL settings

Wei Yongjun (1):
  ixgbe: convert to use simple_open()

 drivers/net/ethernet/intel/igb/igb.h             |   3 +-
 drivers/net/ethernet/intel/igb/igb_ethtool.c     |  56 +----------
 drivers/net/ethernet/intel/igb/igb_main.c        |  51 ++++++----
 drivers/net/ethernet/intel/igb/igb_ptp.c         |  47 ++++-----
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c  |   3 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h  |   1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_debugfs.c | 115 ++++++++++-------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |   5 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |  83 +++++++++-------
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c     |  40 +-------
 10 files changed, 163 insertions(+), 241 deletions(-)

-- 
1.7.11.7
