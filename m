From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 0/9] ixgb: driver update to 1.0.104-k2
Date: Tue, 23 May 2006 11:03:02 -0700
Message-ID: <20060523180302.17428.89125.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke <auke-jan.h.kok"@intel.com,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:37637 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S932065AbWEWR7F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 May 2006 13:59:05 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi,

This is a resend/updated set of patches for ixgb. They were originally
sent earlier on 2005-04-21 by Jeff Kirsher. Some modifications were made
after comments, and this series does not include 2 of the patches sent
at that time (I will resend those modified later).

Summary:

[1] fix rare early tso completion
[2] remove duplicate code setting duplex and speed
[3] fix flow control
[4] add NETIF_F_LLTX analogous to e1000
[5] add copper 10gig driver id
[6] remove hardcoded number
[7] use DPRINTK and msglvl, and ethtool to control it
[8] add tx timeout counter
[9] increment version to 1.0.104-k2


These changes are available through git.

git pull git://lost.foo-projects.org/~ahkok/git/netdev-2.6 ixgb-1.0.104-k2

these patches are against
 netdev-2.6#upstream 4e3ceac609cce39cb96e0eb8604934592371ed8c


Cheers,

Auke


---
 drivers/net/ixgb/ixgb.h         |    9 ++-
 drivers/net/ixgb/ixgb_ethtool.c |   55 ++++++++++------
 drivers/net/ixgb/ixgb_hw.h      |    1 
 drivers/net/ixgb/ixgb_ids.h     |    4 +
 drivers/net/ixgb/ixgb_main.c    |  132 ++++++++++++++++++++++++++++++++-------
 drivers/net/ixgb/ixgb_param.c   |   24 +++----
 6 files changed, 163 insertions(+), 62 deletions(-)

--
Auke Kok <auke-jan.h.kok@intel.com>
