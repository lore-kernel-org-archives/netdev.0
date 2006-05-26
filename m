From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 0/9] ixgb: driver update to 1.0.109-k2
Date: Fri, 26 May 2006 09:51:24 -0700
Message-ID: <20060526165124.30514.78477.stgit@gitlost.site>
Cc: netdev@vger.kernel.org, "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
        "Kok, Auke" <auke-jan.h.kok@intel.com>,
        "Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:26374 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1751116AbWEZQqu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 May 2006 12:46:50 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi,

Here are the ixgb driver updates for 1.0.109-k2. This corresponds with
the release of 1.0.109 on e1000.sf.net, and fixes several issues.

e1000 update will come soon...


Summary:

[1] fix smp polling race condition
[2] fix interface losing macaddr on ifdn/up
[3] revert an unwanted fix regarding tso/descriptors
[4] allocate only buffersize needed
[5] remove lock access in the fast path
[6] remove inlines, allow compiler to choose
[7] replace netdev->priv with netdev_priv()
[8] remove changelog
[9] update version, dates


These changes are available through git.

git pull git://lost.foo-projects.org/~ahkok/git/netdev-2.6 ixgb-1.0.109-k2

these patches are against
 netdev-2.6#upstream a24e2513c2d03c9a92739ec6fa7e7208f792881e


Cheers,

Auke


---
 drivers/net/ixgb/Makefile       |    2 -
 drivers/net/ixgb/ixgb.h         |    2 -
 drivers/net/ixgb/ixgb_ee.c      |    2 -
 drivers/net/ixgb/ixgb_ee.h      |    2 -
 drivers/net/ixgb/ixgb_ethtool.c |    6 +-
 drivers/net/ixgb/ixgb_hw.c      |    2 -
 drivers/net/ixgb/ixgb_hw.h      |    2 -
 drivers/net/ixgb/ixgb_ids.h     |    2 -
 drivers/net/ixgb/ixgb_main.c    |  110 +++++++++++----------------------------
 drivers/net/ixgb/ixgb_osdep.h   |    2 -
 drivers/net/ixgb/ixgb_param.c   |    2 -
 11 files changed, 43 insertions(+), 91 deletions(-)


--
Auke Kok <auke-jan.h.kok@intel.com>
