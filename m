From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/8][pull request] Intel Wired LAN Driver Updates
Date: Tue, 17 Jul 2012 03:09:11 -0700
Message-ID: <1342519759-25137-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:19415 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754368Ab2GQKJW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jul 2012 06:09:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbevf.

The following are changes since commit 282f23c6ee343126156dd41218b22ece96d747e3:
  tcp: implement RFC 5961 3.2
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Alexander Duyck (8):
  ixgbevf: Drop all dead or unnecessary code
  ixgbevf: Drop netdev_registered value since that is already stored in
    netdev
  ixgbevf: Make use of NETIF_F_RXCSUM instead of keeping our own flag
  ixgbevf: Drop use of eitr_low and eitr_high for hard coded values
  ixgbevf: Cleanup accounting for space needed at start of xmit_frame
  ixgbevf: Update q_vector to contain ring pointers instead of bitmaps
  ixgbevf: Move Tx clean-up into NAPI context
  ixgbevf: Use igb style interrupt masks instead of ixgbe style

 drivers/net/ethernet/intel/ixgbevf/defines.h      |   27 +-
 drivers/net/ethernet/intel/ixgbevf/ethtool.c      |   13 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |   99 +--
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |  820 ++++++---------------
 4 files changed, 276 insertions(+), 683 deletions(-)

-- 
1.7.10.4
