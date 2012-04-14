From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/6][pull request] Intel Wired LAN Driver Updates
Date: Sat, 14 Apr 2012 02:16:25 -0700
Message-ID: <1334394991-5839-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:9989 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751114Ab2DNJQe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Apr 2012 05:16:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series of patches contains updates for e100, e1000e, igb and
ixgbe.  The e100 patches from Richard Cochran complete the
time stamping support for e100.

The following are changes since commit 64d683c5825003ffb3b127057a165e6bfc26691e:
  bonding: Fixup get_tx_queue() op second arg type.
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Bruce Allan (2):
  e1000e: cleanup remaining strings split across multiple lines
  e1000e: cleanup boolean logic

Carolyn Wyborny (1):
  igb: Update version to 3.4.7.

Don Skidmore (1):
  ixgbe: add I2C clock stretching

Richard Cochran (2):
  e100: Support the get_ts_info ethtool method.
  e100: enable transmit time stamping.

 drivers/net/ethernet/intel/e100.c               |    2 +
 drivers/net/ethernet/intel/e1000e/80003es2lan.c |    4 +--
 drivers/net/ethernet/intel/e1000e/82571.c       |    9 +++----
 drivers/net/ethernet/intel/e1000e/ethtool.c     |   19 +++++++---------
 drivers/net/ethernet/intel/e1000e/ich8lan.c     |   26 +++++++++++-----------
 drivers/net/ethernet/intel/e1000e/mac.c         |    2 +-
 drivers/net/ethernet/intel/e1000e/manage.c      |    2 +-
 drivers/net/ethernet/intel/e1000e/param.c       |    8 +++---
 drivers/net/ethernet/intel/e1000e/phy.c         |   23 +++++++++----------
 drivers/net/ethernet/intel/igb/igb_main.c       |    4 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c    |   20 ++++++++++++-----
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h   |    1 +
 12 files changed, 62 insertions(+), 58 deletions(-)

-- 
1.7.7.6
