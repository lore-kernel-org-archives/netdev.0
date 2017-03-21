From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/5][pull request] Intel Wired LAN Driver Updates 2017-03-21
Date: Tue, 21 Mar 2017 16:00:23 -0700
Message-ID: <20170321230028.69510-1-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:44539 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758202AbdCUXMv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 21 Mar 2017 19:12:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to e1000, e1000e, igb, igbvf and ixgb.

This finishes up the work Philippe Reynes did to update the Intel drivers
to the new API for ethtool (get|set)_link_ksettings.

The following are changes since commit b3407c8e5eb78e4e0b57a97a4dd2e411354b60cd:
  Cleanup some warning from timestamping code.
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 1GbE

Philippe Reynes (5):
  e1000: use new API ethtool_{get|set}_link_ksettings
  e1000e: use new API ethtool_{get|set}_link_ksettings
  igb: use new API ethtool_{get|set}_link_ksettings
  igbvf: use new API ethtool_{get|set}_link_ksettings
  ixgb: use new API ethtool_{get|set}_link_ksettings

 drivers/net/ethernet/intel/e1000/e1000_ethtool.c | 117 ++++++++++---------
 drivers/net/ethernet/intel/e1000e/ethtool.c      | 111 +++++++++---------
 drivers/net/ethernet/intel/igb/igb_ethtool.c     | 138 ++++++++++++-----------
 drivers/net/ethernet/intel/igbvf/ethtool.c       |  38 +++----
 drivers/net/ethernet/intel/ixgb/ixgb_ethtool.c   |  39 ++++---
 5 files changed, 232 insertions(+), 211 deletions(-)

-- 
2.12.0
