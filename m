From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/2][pull request] 1GbE Intel Wired LAN Driver Updates 2017-06-07
Date: Wed,  7 Jun 2017 22:32:35 -0700
Message-ID: <20170608053237.73040-1-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:30535 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750752AbdFHFcl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Jun 2017 01:32:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains a fix for e1000e and igb.

Colin Ian King fixes sparse warnings in igb by making functions static.

Chris Wilson provides a fix for a previous commit which is causing an
issue during suspend "e1000e_pm_suspend()", where we need to run
e1000e_pm_thaw() if __e1000_shutdown() is unsuccessful.

The following are changes since commit 50dffe7fad6c156c2928e45c19ff7b86eb951f4c:
  Merge branch 'mlx4-drivers-version-update'
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 1GbE

Chris Wilson (1):
  e1000e: Undo e1000e_pm_freeze if __e1000_shutdown fails

Colin Ian King (1):
  igb: make a few local functions static

 drivers/net/ethernet/intel/e1000e/netdev.c |  7 ++++++-
 drivers/net/ethernet/intel/igb/igb_main.c  | 12 ++++++------
 2 files changed, 12 insertions(+), 7 deletions(-)

-- 
2.12.2
