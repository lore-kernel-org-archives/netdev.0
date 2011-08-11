From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 0/4]{pull request] Intel Wired LAN Driver Update
Date: Thu, 11 Aug 2011 15:31:44 -0700
Message-ID: <1313101908-11622-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:53658 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753665Ab1HKWbv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Aug 2011 18:31:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains 4 updates to e1000e, one of which can be
applied to stable kernels back to 2.6.34.

The following are changes since commit a02bc7084501d2edecb0e5b9de56da070db19aa:
  PCnet: Fix section mismatch
and are available in the git repository at:
  master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net master

Bruce Allan (4):
  e1000e: alternate MAC address does not work on device id 0x1060
  e1000e: do not disable receiver on 82574/82583
  e1000e: alternate MAC address update
  e1000e: increase driver version number

 drivers/net/e1000e/82571.c   |    6 ++++--
 drivers/net/e1000e/e1000.h   |    1 +
 drivers/net/e1000e/ethtool.c |    3 ++-
 drivers/net/e1000e/lib.c     |    7 ++++---
 drivers/net/e1000e/netdev.c  |    9 ++++++---
 5 files changed, 17 insertions(+), 9 deletions(-)

-- 
1.7.6

