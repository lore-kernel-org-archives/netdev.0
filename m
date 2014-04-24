From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/13][pull request] Intel Wired LAN Driver Updates
Date: Thu, 24 Apr 2014 03:30:47 -0700
Message-ID: <1398335460-4283-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:11394 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752988AbaDXKbE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Apr 2014 06:31:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to igb only.

Carolyn provides a number of cleanups to fix checkpatch warnings/errors
and two minor issues found by coccicheck.

The following are changes since commit 573be693ce72753c71cb957c2d38fd9cc6d9f568:
  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Carolyn Wyborny (13):
  igb: Cleanups to fix pointer location error
  igb: Cleanups to fix for trailing statement
  igb: Cleanups to change comment style on license headers
  igb: Cleanups to fix assignment in if error
  igb: Cleanups to fix missing break in switch statements
  igb: Cleanups to remove return parentheses
  igb: Cleanups to fix line length warnings
  igb: Cleanups to fix msleep warnings
  igb: Cleanups to fix static initialization
  igb: Cleanups to replace deprecated DEFINE_PCI_DEVICE_TABLE
  igb: Cleanups to remove unneeded extern declaration
  igb: Replace 1/0 return values with true/false
  igb: Change memcpy to struct assignment

 drivers/net/ethernet/intel/igb/e1000_82575.c   | 69 ++++++++++----------
 drivers/net/ethernet/intel/igb/e1000_82575.h   | 50 +++++++--------
 drivers/net/ethernet/intel/igb/e1000_defines.h | 71 +++++++++------------
 drivers/net/ethernet/intel/igb/e1000_hw.h      | 46 ++++++--------
 drivers/net/ethernet/intel/igb/e1000_i210.c    | 48 +++++++-------
 drivers/net/ethernet/intel/igb/e1000_i210.h    | 47 +++++++-------
 drivers/net/ethernet/intel/igb/e1000_mac.c     | 49 +++++++-------
 drivers/net/ethernet/intel/igb/e1000_mac.h     | 47 +++++++-------
 drivers/net/ethernet/intel/igb/e1000_mbx.c     | 47 +++++++-------
 drivers/net/ethernet/intel/igb/e1000_mbx.h     | 47 +++++++-------
 drivers/net/ethernet/intel/igb/e1000_nvm.c     | 46 ++++++--------
 drivers/net/ethernet/intel/igb/e1000_nvm.h     | 47 +++++++-------
 drivers/net/ethernet/intel/igb/e1000_phy.c     | 49 +++++++-------
 drivers/net/ethernet/intel/igb/e1000_phy.h     | 47 +++++++-------
 drivers/net/ethernet/intel/igb/e1000_regs.h    | 47 +++++++-------
 drivers/net/ethernet/intel/igb/igb.h           | 48 +++++++-------
 drivers/net/ethernet/intel/igb/igb_ethtool.c   | 88 ++++++++++++++------------
 drivers/net/ethernet/intel/igb/igb_hwmon.c     | 47 +++++++-------
 drivers/net/ethernet/intel/igb/igb_main.c      | 87 +++++++++++++------------
 19 files changed, 486 insertions(+), 541 deletions(-)

-- 
1.9.0
