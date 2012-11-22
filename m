From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 0/9][pull request] Intel Wired LAN Driver Updates
Date: Thu, 22 Nov 2012 02:11:08 -0800
Message-ID: <1353579077-12097-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:25173 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752493Ab2KVSfw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Nov 2012 13:35:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbe and igb.

v2- drop "ixgbe: eliminate Smatch warnings in ixgbe_debugfs.c" patch while
we validate the suggested changes by Dan Carpenter

The following are changes since commit 76e0d67a08bb195bd0ddea2fcba8c15c85eab243:
  Merge tag 'batman-adv-for-davem' of git://git.open-mesh.org/linux-merge
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

Josh Hay (1):
  ixgbe: Reformat output of ixgbe_dump

Matthew Vick (2):
  igb: Update PTP Rx filters
  igb: No longer rely on APME to determine WoL settings

Wei Yongjun (1):
  ixgbe: convert to use simple_open()

 drivers/net/ethernet/intel/igb/igb.h             |  3 +-
 drivers/net/ethernet/intel/igb/igb_ethtool.c     | 56 +---------------
 drivers/net/ethernet/intel/igb/igb_main.c        | 51 ++++++++++-----
 drivers/net/ethernet/intel/igb/igb_ptp.c         | 47 ++++++--------
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c  |  3 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h  |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_debugfs.c | 32 +--------
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |  5 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    | 83 ++++++++++++++----------
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c     | 40 ++----------
 10 files changed, 117 insertions(+), 204 deletions(-)

-- 
1.7.11.7
