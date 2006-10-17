From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 0/8] e100, e1000: Fixes for netdev-2.6#upstream-fixes
Date: Tue, 17 Oct 2006 12:01:39 -0700
Message-ID: <20061017190139.4194.20128.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:14862 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1751427AbWJQSxq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2006 14:53:46 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi,

The following fixes targeted to netdev-2.6#upstream-fixes are available
through git:

git pull git://lost.foo-projects.org/~ahkok/git/netdev-2.6 upstream-fixes

And apply against 4a1d2d81fa327d095a0a8a1f961bace5b0a2f7da

Cheers,

Auke


---

Jesse Brandeburg <jesse.brandeburg@intel.com>:
     e1000: FIX: don't poke at manageability registers for incompatible adapters
     e1000: FIX: disable LPE for IPV6, only enable for jumbo frames
     e1000: FIX: Don't limit descriptor size to 4kb for PCI-E adapters
     e1000: FIX: move length adjustment due to crc stripping disabled.

Bruce Allan <bruce.w.allan@intel.com>:
     e1000: FIX: fix wrong txdctl threshold bitmasks

Auke Kok <auke-jan.h.kok@intel.com>:
     e1000: FIX: 82542 doesn't support WoL
     e1000: Increment version to 7.2.9-k4
     e100: FIX: fix netconsole fast reboot attached to e100

---

 drivers/net/e100.c                |   52 +++++++++++++++++++++++---------------
 drivers/net/e1000/e1000_ethtool.c |    4 ++
 drivers/net/e1000/e1000_hw.h      |    6 ++--
 drivers/net/e1000/e1000_main.c    |   41 ++++++++++++++++++++---------
 4 files changed, 66 insertions(+), 37 deletions(-)


---
Auke Kok <auke-jan.h.kok@intel.com>
