From: David Daney <ddaney.cavm@gmail.com>
Subject: [PATCH 0/8] netdev/MIPS: Improvements to octeon_mgmt Ethernet driver.
Date: Tue, 21 Aug 2012 11:45:04 -0700
Message-ID: <1345574712-21444-1-git-send-email-ddaney.cavm@gmail.com>
Cc: linux-kernel@vger.kernel.org, David Daney <david.daney@cavium.com>
To: linux-mips@linux-mips.org, ralf@linux-mips.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Daney <david.daney@cavium.com>

Recent additions to the OCTEON SoC family have included enhancements
to the MIX (octeon_mgmt) Ethernet hardware.  These include:

o 1Gig support (up from 100M).

o Hardware timestamping for PTP.

Here we add support for these two features as well as some ethtool
improvements and cleanup of the MAC address handling.

Patch 1/8 is a prerequisite for the rest, and lives in the MIPS
architecture part of the tree.  Since octeon_mgmt devices are only
found in OCTEON SoCs we could merge the whole set via Ralf's tree, or
get Ralf to affix his Acked-by and have it go via the netdev tree.


Chad Reese (1):
  netdev: octeon_mgmt: Add hardware timestamp support.

David Daney (7):
  MIPS: Octeon: Add octeon_io_clk_delay() function.
  netdev: octeon_mgmt: Add support for 1Gig ports.
  netdev: octeon_mgmt: Improve ethtool_ops.
  netdev: octeon_mgmt: Set the parent device.
  netdev: octeon_mgmt: Cleanup and modernize MAC address handling.
  netdev: octeon_mgmt: Remove some useless 'inline'
  netdev: octeon_mgmt: Make multi-line comment style consistent.

 arch/mips/cavium-octeon/csrc-octeon.c     |  93 +++--
 arch/mips/cavium-octeon/setup.c           |   3 +-
 arch/mips/include/asm/octeon/octeon.h     |   1 +
 drivers/net/ethernet/octeon/octeon_mgmt.c | 554 ++++++++++++++++++++++++------
 4 files changed, 512 insertions(+), 139 deletions(-)

-- 
1.7.11.4
