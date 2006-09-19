From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 00/23] e100, e1000, ixgb updates
Date: Tue, 19 Sep 2006 10:26:23 -0700
Message-ID: <20060919172623.4605.56860.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:7949 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1751874AbWISRTg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 13:19:36 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

The following updates are available through git:

git pull git://lost.foo-projects.org/~ahkok/git/netdev-2.6 upstream

And apply against c233289c29369dba7177ca873e9b8ed457af2a78 (Jeff Garzik:
"drivers/net/phy/fixed: #if 0 some incomplete code")

Cheers,

Auke


---

Auke Kok <auke-jan.h.kok@intel.com>:
     e100, e1000, ixgb: update copyright header and remove LICENSE
     e100, e1000, ixgb: Fix an impossible memory overwrite bug
     e100: rework WoL and shutdown handling
     e1000: driver state fixes (race fix)
     e1000: revert 'e1000: Remove 0x1000 as supported device'
     ixgb: convert to netdev_priv(netdev)
     e100, e1000, ixgb: increment version numbers

Bruce Allan <bruce.w.allan@intel.com>:
     e1000: Jumbo frames fixes for 82573
     e1000: handle manageability for pci-e adapters at PHY powerdown
     e1000: don't strip vlan ID if 8021q claims it

Jeff Kirsher <jeffrey.t.kirsher@intel.com>:
     e1000: rename flow control symbols
     e1000: add enums for several link properties
     e1000: allow ethtool to pass arbitrary speed advertisment
     e1000: Fix MANC detection for PCIE adapters
     e1000: gather hardware bit tweaks.
     e1000: add PCI-E capability detection code
     e1000: reduce RAR entries available for ICH8
     e1000: rework polarity, NVM, eeprom code and fixes.

Jesse Brandeburg <jesse.brandeburg@intel.com>:
     e100: Add debugging code for cb cleaning and csum failures.
     e1000: Maybe stop TX if not enough free descriptors
     ixgb: combine more rx descriptors to improve performance

Mitch Williams <mitch.a.williams@intel.com>:
     e1000: add multicast stats counters

Nicholas Nunley <nicholas.d.nunley@intel.com>:
     e1000: remove unused code and make symbols static

---

 drivers/net/e100.c                |  110 +
 drivers/net/e1000/LICENSE         |  339 ++++++
 drivers/net/e1000/Makefile        |   35 
 drivers/net/e1000/e1000.h         |   65 -
 drivers/net/e1000/e1000_ethtool.c |  340 ++----
 drivers/net/e1000/e1000_hw.c      | 2100 ++++++++++++++++++++------------------
 drivers/net/e1000/e1000_hw.h      |  116 --
 drivers/net/e1000/e1000_main.c    |  407 ++-----
 drivers/net/e1000/e1000_osdep.h   |   35 
 drivers/net/e1000/e1000_param.c   |  208 +--
 drivers/net/ixgb/Makefile         |   38 
 drivers/net/ixgb/ixgb.h           |   43 
 drivers/net/ixgb/ixgb_ee.c        |   36 
 drivers/net/ixgb/ixgb_ee.h        |   36 
 drivers/net/ixgb/ixgb_ethtool.c   |   42 
 drivers/net/ixgb/ixgb_hw.c        |   47 
 drivers/net/ixgb/ixgb_hw.h        |   36 
 drivers/net/ixgb/ixgb_ids.h       |   37 
 drivers/net/ixgb/ixgb_main.c      |  190 ---
 drivers/net/ixgb/ixgb_osdep.h     |   36 
 drivers/net/ixgb/ixgb_param.c     |   36 
 21 files changed, 2249 insertions(+), 2083 deletions(-)


---
Auke Kok <auke-jan.h.kok@intel.com>
