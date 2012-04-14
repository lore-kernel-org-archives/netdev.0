From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 0/2][pull request] Intel Wired LAN Driver updates
Date: Sat, 14 Apr 2012 01:51:16 -0700
Message-ID: <1334393478-31885-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:2485 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750933Ab2DNIvX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Apr 2012 04:51:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series of patches contains fixes for e1000e and ixgbe.

The following are changes since commit 3c5e979bd037888dd7d722da22da4b43659af485:
  net: smsc911x: fix skb handling in receive path
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net master

Bruce Allan (1):
  e1000e: issues in Sx on 82577/8/9

Don Skidmore (1):
  ixgbe: fix WoL issue with fiber

 drivers/net/ethernet/intel/e1000e/ich8lan.c   |   15 ++++++++++-----
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   10 ++++++++++
 2 files changed, 20 insertions(+), 5 deletions(-)

-- 
1.7.7.6
