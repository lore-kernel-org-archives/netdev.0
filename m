From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 0/2] e1000: fixes for netpoll+NAPI, ARM
Date: Mon, 05 Jun 2006 16:09:17 -0700
Message-ID: <20060605230917.12584.55755.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:46342 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1750753AbWFEXF7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2006 19:05:59 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi,

This patch series implements two e1000 fixes:

1: fix netpoll with NAPI
2: fix ARM prefetch failure by removing risky prefetches


These changes are available through git:

git://lost.foo-projects.org/~ahkok/git/netdev-2.6 upstream-fixes

these patches are against
 netdev-2.6#upstream-fixes c7812d8ccf1d11f29f752f53727ef6b55bc35150

---

Jeff:

The patch earlier sent regarding:
    e1000: fix irq sharing when running ethtool test
is also still in this branch.

They are intended for jgarzik/netdev-2.6#upstream-fixes.


Cheers,

Auke


---
 drivers/net/e1000/e1000_main.c |   17 ++++++++++-------
  1 files changed, 10 insertions(+), 7 deletions(-)


--
Auke Kok <auke-jan.h.kok@intel.com>
