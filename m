From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/4][pull request] Intel Wired LAN Driver Updates
Date: Fri,  2 Mar 2012 18:26:23 -0800
Message-ID: <1330741587-24073-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:10531 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751515Ab2CCC0b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2012 21:26:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series of patches contains fixes e100 and DCB (ixgbe, bnx2x).

The following are changes since commit b4017c5368f992fb8fb3a2545a0977082c6664e4:
  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Ben Greear (2):
  e100: Fix rx-over-length statistics.
  e100: Show short v/s long rx length errors in ethtool stats.

John Fastabend (2):
  ixgbe: dcb: check setup_tc return codes
  net: dcb: getnumtcs()/setnumtcs() should return an int

 drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c |    4 +-
 drivers/net/ethernet/intel/e100.c               |    8 +++++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c |   30 +++++++++++++++-------
 include/net/dcbnl.h                             |    4 +-
 4 files changed, 31 insertions(+), 15 deletions(-)

-- 
1.7.7.6
