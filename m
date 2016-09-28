From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 0/4][pull request] 1GbE Intel Wired LAN Driver Updates 2016-09-27
Date: Tue, 27 Sep 2016 19:04:57 -0700
Message-ID: <1475028301-122700-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:12751 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752899AbcI1CFD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 27 Sep 2016 22:05:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to igb and igbvf.

Wei Yongjun makes a function static to shut up sparse.

Todd bumps the igb and igbvf version, which is long overdue.

Jake fixes an issue where the PPS SYS_WRAP interrupt was not re-enabled
after a reset, which resulted in disabling of the PPS signaling.

v2: dropped patch 5 of the original series, since the PCI quirk patch
    needs to be reworked by Alex and Sasha to address issues that Bjorn
    Helgaas and Alex Williamson brought up.

The following are changes since commit e96e0eded1335b9cfac71fcdd989d682eb3f8412:
  bnx2x: free the mac filter group list before freeing the cmd
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 1GbE

Jacob Keller (1):
  igb: restore PPS signal on igb_ptp_reset

Todd Fujinaka (2):
  igbvf: bump version to igbvf-2.4.0
  igb: bump version to igb-5.4.0

Wei Yongjun (1):
  igb: fix non static symbol warning

 drivers/net/ethernet/intel/igb/igb.h         | 1 +
 drivers/net/ethernet/intel/igb/igb_ethtool.c | 4 ++--
 drivers/net/ethernet/intel/igb/igb_main.c    | 2 +-
 drivers/net/ethernet/intel/igb/igb_ptp.c     | 5 ++++-
 drivers/net/ethernet/intel/igbvf/netdev.c    | 2 +-
 5 files changed, 9 insertions(+), 5 deletions(-)

-- 
2.7.4
