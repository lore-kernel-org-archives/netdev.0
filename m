From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 0/4] e1000: fixes for 7.1.9-k2
Date: Fri, 14 Jul 2006 16:24:52 -0700
Message-ID: <20060714232452.22378.32866.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>, nhorman@tuxdriver.com,
	jmoyer@redhat.com, mpm@selenic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:6153 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1945907AbWGNXW6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jul 2006 19:22:58 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Jeff,

Please pull the following patches from

git://lost.foo-projects.org/~ahkok/git/netdev-2.6 upstream-fixes-jgarzik
(based on 22e1170310ec6afa41e0dc7ac9dfac735d82dcab)

To receive the following fixes for e1000:

[01]: Redo netpoll fix
[02]: remove CRC bytes from measured packet length
[03]: fix panic on large frame receive when mtu=default
[04]: bump version to 7.1.9-k4

Cheers,

Auke


---
 drivers/net/e1000/e1000.h      |    3 ++
 drivers/net/e1000/e1000_main.c |   52 ++++++++++++++++++++---------------------
 2 files changed, 29 insertions(+), 26 deletions(-)

--
Auke Kok <auke-jan.h.kok@intel.com>
