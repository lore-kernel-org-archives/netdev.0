From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/6][pull request] Intel Wired LAN Driver Updates
Date: Tue, 21 Aug 2012 01:37:49 -0700
Message-ID: <1345538275-1690-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:54114 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754390Ab2HUIh5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Aug 2012 04:37:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ethtool.h, e1000, e1000e, and igb to
implement MDI/MDIx control.

The following are changes since commit 1d76efe1577b4323609b1bcbfafa8b731eda071a:
  team: add support for non-ethernet devices
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Bruce W Allan (1):
  e1000e: implement 82577/579 MDI setting support

Jesse Brandeburg (5):
  ethtool.h: MDI setting support
  igb: implement 580 MDI setting support
  e1000: configure and read MDI settings
  e1000e: implement MDI/MDI-X control
  igb: update to allow reading/setting MDI state

 drivers/net/ethernet/intel/e1000/e1000_ethtool.c | 39 ++++++++++++++++++++++
 drivers/net/ethernet/intel/e1000/e1000_main.c    |  4 +++
 drivers/net/ethernet/intel/e1000e/ethtool.c      | 41 +++++++++++++++++++++--
 drivers/net/ethernet/intel/e1000e/phy.c          | 31 +++++++++++++++--
 drivers/net/ethernet/intel/igb/e1000_phy.c       | 29 ++++++++++++++--
 drivers/net/ethernet/intel/igb/e1000_phy.h       |  5 +--
 drivers/net/ethernet/intel/igb/igb_ethtool.c     | 42 ++++++++++++++++++++++++
 drivers/net/ethernet/intel/igb/igb_main.c        |  4 +++
 include/linux/ethtool.h                          | 17 ++++++----
 9 files changed, 198 insertions(+), 14 deletions(-)

-- 
1.7.11.4
