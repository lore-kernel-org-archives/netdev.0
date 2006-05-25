From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 0/3] ixgb: driver update to 1.0.104-k4
Date: Thu, 25 May 2006 13:25:32 -0700
Message-ID: <20060525202532.25618.58162.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:12806 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1751211AbWEYUV1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 May 2006 16:21:27 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi,

This is another resend of patches sent earlier by Jeff Kirsher and
completes the resend for 1.0.104-kX.


Summary:

[1] add performance enhancements to the buffer_info struct
[2] implement copybreak
[3] increment version to 1.0.104-k4


These changes are available through git.

git pull git://lost.foo-projects.org/~ahkok/git/netdev-2.6 ixgb-1.0.104-k4

these patches are against
 netdev-2.6#upstream c49022b28187de43af673d9c3a31743dd9228c7a


Cheers,

Auke


---
 drivers/net/ixgb/ixgb.h      |    1 
 drivers/net/ixgb/ixgb_main.c |   96 ++++++++++++++++++++++++++++--------------
 2 files changed, 66 insertions(+), 31 deletions(-)


--
Auke Kok <auke-jan.h.kok@intel.com>
