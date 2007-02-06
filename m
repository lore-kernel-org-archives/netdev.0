From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 2.4 0/3] e1000: update to 7.3.20
Date: Mon, 05 Feb 2007 17:01:02 -0800
Message-ID: <20070206010102.28691.96744.stgit@gitlost.site>
Cc: "Garzik, Jeff" <jgarzik@pobox.com>, netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
To: "Willy Tarreau" <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:1245 "EHLO gitlost.site"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S965406AbXBFArl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Feb 2007 19:47:41 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Willy,

Please pull:

git-pull git://lost.foo-projects.org/~ahkok/git/linux-2.4 e1000

to receive an update for the e1000 driver. This updates the e1000
driver in the 2.4 kernel to version 7.3.20-k4, roughly the equivalent
of what is in 2.6.20 and the latest of our out-of-tree driver.

This adds new hardware support and many fixes. Many customers are
asking us for these updates and the current 2.4 kernel ships a very
outdated version of the e1000 adapter.

This patch includes small compatibility headers and code to minimize
the changes we need to make to our driver and keep it in sync easier
with the 2.6 kernel version so we can possibly continue to ship
updates and fixes to this driver with more ease.

Cheers,

Auke


---
These patches apply against commit 99405c24cd80afa8f002574f65700296c838260d

---
Summary:
Jesse Brandeburg <jesse.brandeburg@intel.com>:
     e1000: integrate latest 2.4 linux driver
     [MAINTAINERS]: update e1000 maintainers
     e1000: update README

---
 Documentation/networking/e1000.txt |  785 +++-
 MAINTAINERS                        |   18 
 drivers/net/e1000/Makefile         |    2 
 drivers/net/e1000/e1000.h          |  205 +
 drivers/net/e1000/e1000_ethtool.c  | 1202 ++++---
 drivers/net/e1000/e1000_hw.c       | 5830 +++++++++++++++++++++++++++++--------
 drivers/net/e1000/e1000_hw.h       | 1420 ++++++++-
 drivers/net/e1000/e1000_main.c     | 3897 ++++++++++++++++++------
 drivers/net/e1000/e1000_osdep.h    |   91 
 drivers/net/e1000/e1000_param.c    |  406 +-
 drivers/net/e1000/kcompat.c        |   69 
 drivers/net/e1000/kcompat.h        |  403 ++
 16 files changed, 11305 insertions(+), 3052 deletions(-)

---
Auke Kok <auke-jan.h.kok@intel.com>
