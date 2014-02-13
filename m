From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 0/5] Intel Wired LAN Driver Updates
Date: Thu, 13 Feb 2014 00:00:45 -0800
Message-ID: <1392278450-27062-1-git-send-email-aaron.f.brown@intel.com>
Cc: Aaron Brown <aaron.f.brown@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:61219 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752156AbaBMIDK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Feb 2014 03:03:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to the ixgbe driver.

Don makes recovery from a HW ECC error just schedule a reset as it turns
out the previous behaviour of forcing the user to reload is not necessary.

Jacob adds support for the new SIOCGHWTSTAMP ioctl, removes a magic number
from the ptp_caps.name assignment and makes a warning message much more
useful.

Mark add WOL support for a new part.

Don Skidmore (1):
  ixgbe: modify behavior on receiving a HW ECC error.

Jacob Keller (3):
  ixgbe: implement SIOCGHWTSTAMP ioctl
  ixgbe: don't use magic size number to assign ptp_caps.name
  ixgbe: fixup warning regarding max_vfs parameter

Mark Rustad (1):
  ixgbe: Add WoL support for a new device

 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |  5 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 37 +++++++++++++++++------
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c  | 43 +++++++++++++++++----------
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h |  1 +
 4 files changed, 60 insertions(+), 26 deletions(-)

-- 
1.8.5.GIT
