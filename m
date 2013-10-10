From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/13][pull request] Intel Wired LAN Driver Updates
Date: Wed,  9 Oct 2013 23:40:58 -0700
Message-ID: <1381387271-29605-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:46635 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752137Ab3JJGlQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Oct 2013 02:41:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e only.

Alex provides the majority of the patches against i40e, where he does
cleanup of the Tx and RX queues and to align the code with the known
good Tx/Rx queue code in the ixgbe driver.

Anjali provides an i40e patch to update link events to not print to
the log until the device is administratively up.

Catherine provides a patch to update the driver version.

The following are changes since commit b68656b22fd7a3e03087c11b2b45c15c0b328609:
  be2net: change the driver version number to 4.9.224.0
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Alexander Duyck (11):
  i40e: Drop unused completed stat
  i40e: Cleanup Tx buffer info layout
  i40e: Do not directly increment Tx next_to_use
  i40e: clean up Tx fast path
  i40e: Drop dead code and flags from Tx hotpath
  i40e: Add support for Tx byte queue limits
  i40e: Split bytes and packets from Rx/Tx stats
  i40e: Move q_vectors from pointer to array to array of pointers
  i40e: Replace ring container array with linked list
  i40e: Move rings from pointer to array to array of pointers
  i40e: Add support for 64 bit netstats

Anjali Singhai (1):
  i40e: Link code updates

Catherine Sullivan (1):
  i40e: Bump version

 drivers/net/ethernet/intel/i40e/i40e.h         |  11 +-
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c | 207 ++++++------
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c |  69 ++--
 drivers/net/ethernet/intel/i40e/i40e_main.c    | 442 ++++++++++++++++---------
 drivers/net/ethernet/intel/i40e/i40e_txrx.c    | 358 ++++++++++----------
 drivers/net/ethernet/intel/i40e/i40e_txrx.h    |  35 +-
 6 files changed, 650 insertions(+), 472 deletions(-)

-- 
1.8.3.1
