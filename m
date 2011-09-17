From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/11][pull request] Intel Wired LAN Driver Updates
Date: Fri, 16 Sep 2011 19:15:41 -0700
Message-ID: <1316225752-1709-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:30296 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753218Ab1IQCP4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Sep 2011 22:15:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains updates to ixgb and ixgbe. The ixgb patch
does the conversion to ndo_fix_features.  The remaining patches are for
ixgbe to do the following:=20

  - cleanup register reads, comments, memory allocations
  - add SFP support for 82598 PHY and overheat sensor code
  - fix register dump for X50

The following are changes since commit f78a5fda9116525809d088917638be91=
2b85f838:
  Revert "Scm: Remove unnecessary pid & credential references in Unix s=
ocket's send and receive path"
and are available in the git repository at:
  git://github.com/Jkirsher/net-next.git

Alexander Duyck (7):
  ixgbe: remove redundant configuration of tx_sample_rate
  v2 ixgbe: Update packet buffer reservation to correct fdir headroom
    size
  ixgbe: make ixgbe_up and ixgbe_up_complete void functions
  ixgbe: Add missing code for enabling overheat sensor interrupt
  ixgbe: Add SFP support for missed 82598 PHY
  ixgbe: drop adapter from ixgbe_fso call documentation
  ixgbe: Make better use of memory allocations in one-buffer mode w/
    RSC

Emil Tantilov (3):
  ixgbe: cleanup some register reads
  ixgbe: fix FCRTL/H register dump for X540
  ixgbe: remove duplicate netif_tx_start_all_queues

Micha=C5=82 Miros=C5=82aw (1):
  ixgb: convert to ndo_fix_features

 drivers/net/ethernet/intel/ixgb/ixgb.h           |    2 +
 drivers/net/ethernet/intel/ixgb/ixgb_ethtool.c   |   59 +----------
 drivers/net/ethernet/intel/ixgb/ixgb_main.c      |   31 +++++-
 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |   13 ++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |    3 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c    |    1 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |  126 ++++++++++++--=
--------
 7 files changed, 112 insertions(+), 123 deletions(-)

--=20
1.7.6
