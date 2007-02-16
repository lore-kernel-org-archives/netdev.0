From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 0/3] e1000: fix, two minor updates
Date: Fri, 16 Feb 2007 14:39:13 -0800
Message-ID: <20070216223913.26963.76602.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
To: "Garzik, Jeff" <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:1341 "EHLO gitlost.site"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1946091AbXBPWZH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Feb 2007 17:25:07 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Jeff,

Please pull:

git-pull git://lost.foo-projects.org/~ahkok/git/netdev-2.6 e1000

to receive one fix (patch 1) and 2 updates to the e1000 driver.

Cheers,

Auke

---
Summary:
Jesse Brandeburg <jesse.brandeburg@intel.com>: (1)
     e1000: fix shared interrupt warning message

Auke Kok <auke-jan.h.kok@intel.com>: (2)
     e1000: allow ethtool to see link status when down
     e1000: remove obsolete custom pci_save_state code

---
 drivers/net/e1000/e1000.h         |    1 
 drivers/net/e1000/e1000_ethtool.c |    2 -
 drivers/net/e1000/e1000_main.c    |   70 ++++----------------------------------
 3 files changed, 9 insertions(+), 64 deletions(-)

---
These patches appply against torvalds/linux-2.6 #master as of
commit 0187f221e96e3436d552c0c7143f183eb82fb658 ( Ben Dooks --
"[PATCH] s3c2410fb: fix un-initialised dev field")

