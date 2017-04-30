From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/4][pull request] 1GbE Intel Wired LAN Driver Updates 2017-04-30
Date: Sun, 30 Apr 2017 05:36:10 -0700
Message-ID: <20170430123614.67897-1-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:38083 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935318AbdD3MgS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 30 Apr 2017 08:36:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to e1000e only.

Jarod Wilson fixes an issue where the workaround for 82574 & 82583
is needed for i218 as well, so set the appropriate flags.

Sasha adds support for the upcoming new i219 devices for the client
platform (CannonLake), which includes the support for 38.4MHz frequency
to support PTP on CannonLake.

The following are changes since commit c08bac03d2894113bdb114e66e6ada009defb120:
  Merge branch '10GbE' of git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 1GbE

Jarod Wilson (1):
  e1000e: fix PTP on e1000_pch_lpt variants

Sasha Neftin (3):
  e1000e: Initial Support for CannonLake
  e1000e: Add Support for CannonLake
  e1000e: Add Support for 38.4MHZ frequency

 drivers/net/ethernet/intel/e1000e/e1000.h   |  28 +++++---
 drivers/net/ethernet/intel/e1000e/ethtool.c |  10 +--
 drivers/net/ethernet/intel/e1000e/hw.h      |   5 ++
 drivers/net/ethernet/intel/e1000e/ich8lan.c | 105 +++++++++++++++++-----------
 drivers/net/ethernet/intel/e1000e/netdev.c  |  83 +++++++++++++---------
 drivers/net/ethernet/intel/e1000e/ptp.c     |   4 +-
 6 files changed, 144 insertions(+), 91 deletions(-)

-- 
2.12.2
