From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/8][pull request] Intel Wired LAN Driver Updates
Date: Sun, 16 Sep 2012 21:15:34 -0700
Message-ID: <1347855342-6610-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:44766 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750728Ab2IQEPr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Sep 2012 00:15:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to e1000 and ixgbe.  Most notably is
the added debugfs support in ixgbe.

The following are changes since commit 7f2e6a5d8608d0353b017a0fe15502307593734e:
  drivers/isdn/gigaset/common.c: Remove useless kfree
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Alexander Duyck (2):
  ixgbe: Fix ordering of things so that PF correctly configures its
    VLANs
  ixgbe: Fix VF rate limiting to correctly account for more queues per
    VF

Catherine Sullivan (3):
  ixgbe: add debugfs support
  ixgbe: added netdev_ops file to debugfs
  ixgbe: added reg_ops file to debugfs

Emil Tantilov (1):
  ixgbe: fix reporting of spoofed packets

Mark Rustad (1):
  ixgbe: Improve statistics accuracy for DDP traffic

Otto Estuardo Solares Cabrera (1):
  e1000: add byte queue limits

 drivers/net/ethernet/intel/e1000/e1000_main.c    |  10 +
 drivers/net/ethernet/intel/ixgbe/Makefile        |   2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |  10 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_debugfs.c | 300 +++++++++++++++++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |  60 +++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c   | 105 ++++----
 6 files changed, 423 insertions(+), 64 deletions(-)
 create mode 100644 drivers/net/ethernet/intel/ixgbe/ixgbe_debugfs.c

-- 
1.7.11.4
