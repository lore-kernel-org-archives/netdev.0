From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 0/6] Intel Wired LAN Driver Updates
Date: Tue, 25 Feb 2014 17:58:52 -0800
Message-ID: <1393379938-1415-1-git-send-email-aaron.f.brown@intel.com>
Cc: Aaron Brown <aaron.f.brown@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:48765 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751010AbaBZCCP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Feb 2014 21:02:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbe, igb and documentation.  The
first four have been sent up as part of other series where 1 or more
in the series were rejected and either dropped or still being worked
on for reasons unrelated to these patches.

Don makes recovery from a HW ECC error just schedule a reset as it turns
out the previous behaviour of forcing the user to reload is not necessary.
Mark adds WoL support to port 0 of a new device.  Jacob removes a magic
number from the ptp_caps.name and updates the SubmittingPatches
documentation with details on the Fixed: tag.  And Carolyn updates igb
files to remove the FSF physical mail address.

Don Skidmore (1):
  ixgbe: modify behavior on receiving a HW ECC error.

Mark Rustad (1):
  ixgbe: Add WoL support for a new device

Jeff Kirsher (1):
  igb: make local functions static and remove dead code

Jacob Keller (2):
  ixgbe: don't use magic size number to assign ptp_caps.name
  doc: update SubmittingPatches about the Fixed tag

Carolyn Wyborny (1):
  igb: Update license text to remove FSF address and update copyright.

 Documentation/SubmittingPatches                | 14 ++++-
 drivers/net/ethernet/intel/igb/Makefile        |  5 +-
 drivers/net/ethernet/intel/igb/e1000_82575.c   |  9 ++-
 drivers/net/ethernet/intel/igb/e1000_82575.h   |  7 +--
 drivers/net/ethernet/intel/igb/e1000_defines.h |  5 +-
 drivers/net/ethernet/intel/igb/e1000_hw.h      |  5 +-
 drivers/net/ethernet/intel/igb/e1000_i210.c    | 25 +++++----
 drivers/net/ethernet/intel/igb/e1000_i210.h    | 14 +----
 drivers/net/ethernet/intel/igb/e1000_mac.c     |  5 +-
 drivers/net/ethernet/intel/igb/e1000_mac.h     |  5 +-
 drivers/net/ethernet/intel/igb/e1000_mbx.c     |  5 +-
 drivers/net/ethernet/intel/igb/e1000_mbx.h     |  5 +-
 drivers/net/ethernet/intel/igb/e1000_nvm.c     |  5 +-
 drivers/net/ethernet/intel/igb/e1000_nvm.h     |  5 +-
 drivers/net/ethernet/intel/igb/e1000_phy.c     | 76 +-------------------------
 drivers/net/ethernet/intel/igb/e1000_phy.h     |  6 +-
 drivers/net/ethernet/intel/igb/e1000_regs.h    |  5 +-
 drivers/net/ethernet/intel/igb/igb.h           |  7 +--
 drivers/net/ethernet/intel/igb/igb_ethtool.c   |  5 +-
 drivers/net/ethernet/intel/igb/igb_hwmon.c     |  5 +-
 drivers/net/ethernet/intel/igb/igb_main.c      |  7 +--
 drivers/net/ethernet/intel/igb/igb_ptp.c       | 11 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  | 19 +++++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c   |  8 ++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h  |  1 +
 25 files changed, 93 insertions(+), 171 deletions(-)

-- 
1.8.5.GIT
