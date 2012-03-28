From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 0/4][pull request] Intel Wired LAN Driver Updates
Date: Tue, 27 Mar 2012 23:52:24 -0700
Message-ID: <1332917548-13102-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:1117 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751082Ab2C1Gwb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Mar 2012 02:52:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series of patches contains fixes for e1000, igb, igbvf, ixgb,
ixgbe and ixgbevf.

The following are changes since commit cc3425cdc04206f3c8b9efb2c693e89aa3cd9ec7:
  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net master

Don Skidmore (2):
  ixgbe: fix typo in enumeration name
  ixgbe: update version number

Jiri Pirko (1):
  e1000: fix vlan processing regression

stephen hemminger (1):
  intel: make wired ethernet driver message level consistent (rev2)

 drivers/net/ethernet/intel/e1000/e1000_main.c     |   40 +++++++++++++--------
 drivers/net/ethernet/intel/e1000e/netdev.c        |    7 +++-
 drivers/net/ethernet/intel/igb/igb_main.c         |    7 +++-
 drivers/net/ethernet/intel/igbvf/netdev.c         |    7 +++-
 drivers/net/ethernet/intel/ixgb/ixgb_main.c       |    6 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe.h          |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |   13 ++++---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |    7 +++-
 8 files changed, 60 insertions(+), 29 deletions(-)

-- 
1.7.7.6
