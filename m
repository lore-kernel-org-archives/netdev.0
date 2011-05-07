From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 0/5][pull request] Intel Wired LAN Driver Update
Date: Sat,  7 May 2011 03:25:18 -0700
Message-ID: <1304763923-6839-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:43819 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754415Ab1EGKZ1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 May 2011 06:25:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains updates to e100, e1000, igb and ixgbe.

Sorry for the delay on the e100/e1000/igb convert to set_phys_id patches,
it was due to me falling ill and not completing the patches in a timely
manner.

The following are changes since commit 706527280ec38fcdcd0466f10b607105fd23801b:
  ipv4: Initialize cork->opt using NULL not 0
and are available in the git repository at:
  master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net-next-2.6 master

Emil Tantilov (2):
  ixgbe: add rxhash support
  ixgbe: add ethtool counters for OS2BMC

Jeff Kirsher (3):
  e100: implemenet set_phys_id
  e1000: convert to set_phys_id
  igb: convert to ethtool set_phys_id

 drivers/net/e100.c                |   66 +++++++++++++++---------------------
 drivers/net/e1000/e1000.h         |    3 --
 drivers/net/e1000/e1000_ethtool.c |   50 +++++++++-------------------
 drivers/net/igb/igb_ethtool.c     |   37 ++++++++++----------
 drivers/net/ixgbe/ixgbe_ethtool.c |   11 +++++-
 drivers/net/ixgbe/ixgbe_main.c    |   21 ++++++++++-
 drivers/net/ixgbe/ixgbe_type.h    |    8 ++++
 7 files changed, 100 insertions(+), 96 deletions(-)

-- 
1.7.4.4

