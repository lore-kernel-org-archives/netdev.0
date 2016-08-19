From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/4][pull request] 1GbE Intel Wired LAN Driver Updates 2016-08-18
Date: Thu, 18 Aug 2016 22:30:46 -0700
Message-ID: <1471584650-14645-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:19872 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754215AbcHSFax (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 19 Aug 2016 01:30:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to igb only.

Gangfeng Huang provides all the changes in the series to update the
igb driver to support advanced receive side filters that direct receive
packets by flows to different hardware queues. This enables a tight
control on routing a flow in the platform.  First patch allows for
receive network flow classification to insert and remove receive filters
by ethtool.  Second and third patches add the ability to insert and
remove ethertype and VLAN priority filters by ethtool.

Last patch just fixes an error message to return "Not supported" versus
"Unknown error 524".

The following are changes since commit e951f145d1724769546efe2e04f6cb2b7037d7ea:
  Merge branch 'tipc-next'
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 1GbE

Gangfeng Huang (4):
  igb: add support of RX network flow classification
  igb: support RX flow classification by ethertype
  igb: support RX flow classification by VLAN priority
  igb: fix error code in igb_add_ethtool_nfc_entry()

 drivers/net/ethernet/intel/igb/e1000_82575.h   |   5 +
 drivers/net/ethernet/intel/igb/e1000_defines.h |   4 +
 drivers/net/ethernet/intel/igb/e1000_regs.h    |   1 +
 drivers/net/ethernet/intel/igb/igb.h           |  50 ++++
 drivers/net/ethernet/intel/igb/igb_ethtool.c   | 345 +++++++++++++++++++++++++
 drivers/net/ethernet/intel/igb/igb_main.c      |  45 ++++
 drivers/net/ethernet/intel/igb/igb_ptp.c       |   4 +-
 7 files changed, 452 insertions(+), 2 deletions(-)

-- 
2.7.4
