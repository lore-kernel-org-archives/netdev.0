From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/9][pull request] Intel Wired LAN Driver Updates
Date: Thu,  6 Oct 2011 04:02:30 -0700
Message-ID: <1317898959-16550-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:30733 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754701Ab1JFLCl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Oct 2011 07:02:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains updates to e1000e, igb and ixgbe.  Here
is a quick summary:
  - e1000e: fixes for 2 WoL issues
  - igb: fix for I2C, and 2 Alt. MAC address updates
  - ixgbe: fix dependencies for 8 traffic classes, add X540 traffic
    class support and a fix for PFC mask generation

The following are changes since commit f0cd7bdc042310b6b104f133bbfd520a72b3c08a:
  bnx2x: remove some dead code
and are available in the git repository at
  git://github.com/Jkirsher/net-next.git

Akeem G. Abodunrin (3):
  igb: Code to prevent overwriting SFP I2C
  igb: Alternate MAC Address EEPROM Updates
  igb: Alternate MAC Address Updates for Func2&3

Bruce Allan (2):
  e1000e: WoL can fail on 82578DM
  e1000e: WoL fails on device ID 0x1501

John Fastabend (3):
  ixgbe: fixup hard dependencies on supporting 8 traffic classes
  ixgbe: DCB X540 devices support max traffic class of 4
  ixgbe: X540 devices RX PFC frames pause traffic even if disabled

Mark Rustad (1):
  ixgbe: Fix PFC mask generation

 drivers/net/ethernet/intel/e1000e/ich8lan.c        |   25 +++++---
 drivers/net/ethernet/intel/igb/e1000_mac.c         |    9 ++-
 drivers/net/ethernet/intel/igb/e1000_phy.c         |    6 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c       |   22 ++++++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.h       |    3 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.c |   46 ++++++++++++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.h |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c    |   60 +++++++++++++++-----
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |   29 ++++++++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h      |    3 +-
 10 files changed, 158 insertions(+), 47 deletions(-)

-- 
1.7.6.4
