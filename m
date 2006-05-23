From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 0/6] e1000: update to 7.0.38-k4
Date: Tue, 23 May 2006 14:07:40 -0700
Message-ID: <20060523210740.18540.56647.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:56069 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S932228AbWEWVDj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 May 2006 17:03:39 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi,

These e1000 patches include a fix for WOL and some driver cleanups:

[1]: add shutdown handler back to fix WOL
[2]: remove backslash r debug printfs
[3]: remove leading and trailing whitespace.
[4]: Fix date string in Makefile
[5]: remove changelog in driver
[6]: bump version to 7.0.38-k4


Jeff, please pull from:

git://lost.foo-projects.org/~ahkok/git/netdev-2.6 e1000-7.0.38-k4


These patches are against
 netdev-2.6#upstream 4e3ceac609cce39cb96e0eb8604934592371ed8c

Cheers,

Auke


---
 drivers/net/e1000/Makefile        |    2 -
 drivers/net/e1000/e1000_ethtool.c |   44 +++++++--------
 drivers/net/e1000/e1000_hw.c      |  112 +++++++++++++++++++------------------
 drivers/net/e1000/e1000_hw.h      |    4 +
 drivers/net/e1000/e1000_main.c    |   77 ++++++++-----------------
 5 files changed, 104 insertions(+), 135 deletions(-)

--
Auke Kok <auke-jan.h.kok@intel.com>
