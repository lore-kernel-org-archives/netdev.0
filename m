From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 0/2][pull request] Intel Wired LAN Driver Updates 2016-06-29
Date: Wed, 29 Jun 2016 09:30:02 -0700
Message-ID: <1467217804-137463-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:20511 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750932AbcF2Qdj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jun 2016 12:33:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains fixes to e1000e and ixgbevf.

Jarod Wilson's fix for e1000e was a follow-on patch to his previous fix to
keep the hardware VLAN CTAG's for receive and transmit in sync, which
in turn resolves the original issue, so revert a portion of the original
fix.

Xin Long noticed that the ret_val needed to be initialized to IXGBE_ERR_MBX,
instead of -IXGBE_ERR_MBX.

The following are changes since commit 751ad819b0bf443ad8963eb7bfbd533e6a463973:
  Merge tag 'mac80211-for-davem-2016-06-29-v2' of git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-queue master

Jarod Wilson (1):
  e1000e: keep Rx/Tx HW_VLAN_CTAG in sync

Xin Long (1):
  ixgbevf: ixgbevf_write/read_posted_mbx should use IXGBE_ERR_MBX to
    initialize ret_val

 drivers/net/ethernet/intel/e1000e/netdev.c | 21 +++++++++------------
 drivers/net/ethernet/intel/ixgbevf/mbx.c   |  4 ++--
 2 files changed, 11 insertions(+), 14 deletions(-)

-- 
2.5.5
