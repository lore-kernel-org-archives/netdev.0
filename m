From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 00/10][pull request] Intel Wired LAN Driver Update
Date: Wed,  2 Nov 2011 17:19:51 -0700
Message-ID: <1320279601-1276-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:37902 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754192Ab1KCAUD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Nov 2011 20:20:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains fixes to e100, e1000e, igb, ixgbe and
ixgbevf.  The bulk of the fixes are to ixgbe.  Here is a summary
of the changes:

e100 - make sure VLAN support is not advertised for older adapters
e1000e - fix a debugging message
igb -  fix a PHY cable length unit detection
ixgbe - fix the following: link issues, reading of buffer, disable Tx
  laser at probe, compiler warnings, missing NULL check and DCB IEEE
  traffic classes
ixgbevf - bump version

The following are changes since commit 2edcd4ca43df3c1d1d392753531cc73a53e709ba:
  net: fix typo in drivers/net/ethernet/xilinx/ll_temac_main.c
and are available in the git repository at
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net.git

Bruce Allan (1):
  e1000e: demote a debugging WARN to a debug log message

Emil Tantilov (3):
  ixgbe: Fix link issues caused by a reset while interface is down
  ixgbe: fix disabling of Tx laser at probe
  ixgbe: fix reading of the buffer returned by the firmware

Greg Rose (2):
  ixgbe: Fix compiler warnings
  ixgbevf: Update release version

Jesse Brandeburg (1):
  e100: make sure vlan support isn't advertised on old adapters

John Fastabend (2):
  ixgbe: fix smatch splat due to missing NULL check
  ixgbe: DCB, return max for IEEE traffic classes

Kantecki, Tomasz (1):
  igb: Fix for I347AT4 PHY cable length unit detection

 drivers/net/ethernet/intel/e100.c                 |    4 ++
 drivers/net/ethernet/intel/e1000e/ich8lan.c       |    3 +-
 drivers/net/ethernet/intel/igb/e1000_phy.c        |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c   |   20 +++++----
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c   |   10 +++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |   48 ++++++++------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h    |    2 +
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |    2 +-
 8 files changed, 45 insertions(+), 46 deletions(-)

-- 
1.7.6.4
