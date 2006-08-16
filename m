From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 00/13] e100, e1000, ixgb fixes
Date: Wed, 16 Aug 2006 14:53:36 -0700
Message-ID: <20060816215336.27080.56147.stgit@gitlost.site>
Cc: netdev@vger.kernel.org, akpm@osdl.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:50441 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S932250AbWHPVs1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2006 17:48:27 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi,

Here are updates targeted to branch #upstream-fixes from netdev-2.6, including
fixes to e100, e1000 and ixgb.

Summary:
---

Manasi Deval
    ixgb: Add CX4 PHY type detection and subdevice ID.

Jesse Brandeburg
    e1000: Explicitly power up the PHY during loopback testing.
    e1000: Explicit locking for two ethtool path functions
    ixgb:  Fix cache miss due to miscalculation

Jeff Kirsher
    e1000: Remove 0x1000 as supported device
    e1000: Allow NVM to setup LPLU for IGP2 and IGP3
    e1000: Force full DMA clocking for 10/100 speed
    e1000: Disable aggressive clocking on esb2 with SERDES port
    e100:  Remove auto-MDIO/MDIO-X workaround

Auke Kok
    e1000: Same ntohs/htons cosmetic fix as for ipv6
    e1000: Increment driver version to 7.1.9-k6
    e100:  Increment version to 3.5.10-k4
    ixgb:  Increment version to 1.0.109-k4

---

These changes are available through git.

git pull git://lost.foo-projects.org/~ahkok/git/netdev-2.6 upstream-fixes

these patches are against
 netdev-2.6#upstream-fixes 09e590e5d5a93f2eaa748a89c623258e6bad1648


Cheers,

Auke

---
 drivers/net/e100.c                |   22 ++++++++------------
 drivers/net/e1000/e1000_ethtool.c |   40 ++++++++++++++++++++++++++++----------
 drivers/net/e1000/e1000_hw.c      |   24 ++++++++++++++++++----
 drivers/net/e1000/e1000_main.c    |    9 ++------
 drivers/net/ixgb/ixgb_hw.c        |   11 ++++++++++
 drivers/net/ixgb/ixgb_ids.h       |    1 
 drivers/net/ixgb/ixgb_main.c      |   14 ++++++-------
 7 files changed, 80 insertions(+), 41 deletions(-)

--
Auke Kok <auke-jan.h.kok@intel.com>
