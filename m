From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/9][pull request] Intel Wired LAN Driver Updates
Date: Wed, 20 Jun 2012 01:44:54 -0700
Message-ID: <1340181903-16382-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:31665 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751768Ab2FTIpG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jun 2012 04:45:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to e1000, igb and ixgbe

The following are changes since commit 41063e9dd11956f2d285e12e4342e1d232ba0ea2:
  ipv4: Early TCP socket demux.
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Carolyn Wyborny (4):
  igb: Add switch case for supported hardware to igb_ptp_remove.
  igb: Support the get_ts_info ethtool method.
  igb: Update firmware info output
  igb: Version bump

Jacob Keller (2):
  ixgbe: add support for 1G SX modules
  ixgbe: clean up ixgbe_get_settings ethtool function

Lior Levy (1):
  igb: A fix to VF TX rate limit

Matthew Vick (1):
  igb: Streamline RSS queue and queue pairing assignment logic.

Tushar Dave (1):
  e1000: Combining Bitwise OR in one expression.

 drivers/net/ethernet/intel/e1000/e1000_main.c    |   12 +-
 drivers/net/ethernet/intel/igb/e1000_regs.h      |    1 +
 drivers/net/ethernet/intel/igb/igb.h             |   25 +++-
 drivers/net/ethernet/intel/igb/igb_ethtool.c     |   52 ++++++--
 drivers/net/ethernet/intel/igb/igb_main.c        |  156 +++++++++++++++++-----
 drivers/net/ethernet/intel/igb/igb_ptp.c         |   12 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c   |    4 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |  147 +++++++++-----------
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c     |   23 +++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h    |    2 +
 10 files changed, 291 insertions(+), 143 deletions(-)

-- 
1.7.10.2
