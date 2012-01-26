From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/12][pull request] Intel Wired LAN Driver Updates
Date: Wed, 25 Jan 2012 23:21:43 -0800
Message-ID: <1327562515-29664-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:54466 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751022Ab2AZHV5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jan 2012 02:21:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains updates to e1000e only.  Most of these
changes contain fixup/cleanups/conversions.

The following are changes since commit e55684fadbc5c9c69cad1b3bae228c8374b99b85:
  infiniband: nes: Convert nes_addr_resolve_neigh() over to dst_neigh_lookup().
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

  e1000e: cleanup Rx checksum offload code
  e1000e: add Receive Packet Steering (RPS) support
  e1000e: re-enable alternate MAC address for all devices which support
    it
  e1000e: convert head, tail and itr_register offsets to __iomem
    pointers
  e1000e: pass pointer to ring struct instead of adapter struct
  e1000e: re-factor ethtool get/set ring parameter
  e1000e: default IntMode based on kernel config & available hardware
    support
  e1000e: always set transmit descriptor control registers the same
  e1000e: 82579: workaround for link drop issue
  e1000e: use default settings for Tx Inter Packet Gap timer
  e1000e: use hardware default values for Transmit Control register
  e1000e: 82574/82583 Tx hang workaround

 drivers/net/ethernet/intel/e1000e/80003es2lan.c |    3 +-
 drivers/net/ethernet/intel/e1000e/82571.c       |    4 +
 drivers/net/ethernet/intel/e1000e/defines.h     |    8 +
 drivers/net/ethernet/intel/e1000e/e1000.h       |   29 +-
 drivers/net/ethernet/intel/e1000e/ethtool.c     |  186 +++++++----
 drivers/net/ethernet/intel/e1000e/hw.h          |    9 +-
 drivers/net/ethernet/intel/e1000e/ich8lan.c     |   22 ++
 drivers/net/ethernet/intel/e1000e/lib.c         |    7 +-
 drivers/net/ethernet/intel/e1000e/netdev.c      |  423 +++++++++++++----------
 drivers/net/ethernet/intel/e1000e/param.c       |   48 +++-
 10 files changed, 471 insertions(+), 268 deletions(-)

-- 
1.7.7.6
