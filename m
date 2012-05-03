From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/9][pull request] Intel Wired LAN Dirver Updates
Date: Thu,  3 May 2012 02:56:23 -0700
Message-ID: <1336038992-3144-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:64596 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751941Ab2ECJ4e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 May 2012 05:56:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series of patches contains updates for e1000e and ixgbevf.

The following are changes since commit af94bf6db1d58d26f1cdab145b6312ad363254a6:
  ixgbe: Fix use after free on module remove
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Bruce Allan (2):
  e1000e: suggest a possible workaround to a device hang on 82577/8
  e1000e: cleanup long [read|write]_reg_locked PHY ops function
    pointers

Chris Boot (2):
  e1000e: Disable ASPM L1 on 82574
  e1000e: Remove special case for 82573/82574 ASPM L1 disablement

Greg Rose (3):
  ixgbevf: Add support to recognize 100mb link speed
  ixgbevf: Make sure jumbo frames are set correctly after PF reset
  ixgbevf: Update version string

Matthew Vick (2):
  e1000e: Resolve intermittent negotiation issue on 82574/82583.
  e1000e: Driver workaround for IPv6 Header Extension Erratum.

 drivers/net/ethernet/intel/e1000e/80003es2lan.c   |    8 +++
 drivers/net/ethernet/intel/e1000e/82571.c         |   13 +++++-
 drivers/net/ethernet/intel/e1000e/e1000.h         |   10 ++++
 drivers/net/ethernet/intel/e1000e/ich8lan.c       |   54 ++++++++++-----------
 drivers/net/ethernet/intel/e1000e/netdev.c        |   21 ++------
 drivers/net/ethernet/intel/e1000e/phy.c           |   18 +++++++-
 drivers/net/ethernet/intel/ixgbevf/defines.h      |    2 +
 drivers/net/ethernet/intel/ixgbevf/ethtool.c      |   18 +++++--
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |    2 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   30 ++++++------
 drivers/net/ethernet/intel/ixgbevf/vf.c           |   12 ++++-
 11 files changed, 119 insertions(+), 69 deletions(-)

-- 
1.7.7.6
