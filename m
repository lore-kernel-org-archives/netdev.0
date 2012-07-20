From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/6][pull request] Intel Wired LAN Driver Updates
Date: Fri, 20 Jul 2012 14:43:45 -0700
Message-ID: <1342820631-19738-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:41709 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750711Ab2GTVny (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jul 2012 17:43:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ethtool, e1000, e1000e and igb with
regards to the new MDI ethtool support patches submitted earlier.

The following are changes since commit fa0afcd10951afad2022dda09777d2bf70cdab3d:
  atl1c: fix issue of io access mode for AR8152 v2.1
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

 drivers/net/ethernet/intel/e1000/e1000_ethtool.c |   34 +++++++++++++++++++
 drivers/net/ethernet/intel/e1000/e1000_main.c    |    4 +++
 drivers/net/ethernet/intel/e1000e/ethtool.c      |   39 +++++++++++++++++++---
 drivers/net/ethernet/intel/e1000e/phy.c          |   31 +++++++++++++++--
 drivers/net/ethernet/intel/igb/e1000_phy.c       |   29 ++++++++++++++--
 drivers/net/ethernet/intel/igb/e1000_phy.h       |    5 +--
 drivers/net/ethernet/intel/igb/igb_ethtool.c     |   37 ++++++++++++++++++++
 drivers/net/ethernet/intel/igb/igb_main.c        |    4 +++
 include/linux/ethtool.h                          |   17 ++++++----
 9 files changed, 184 insertions(+), 16 deletions(-)

-- 
1.7.10.4
