From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH 0/4] Fixes for unified offload configuration
Date: Wed, 23 Feb 2011 03:52:28 +0100 (CET)
Message-ID: <cover.1298429033.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:47059 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751195Ab1BWCwa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Feb 2011 21:52:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

this series contains couple of fixes to ethtool unification work in net=
-next.

patches 1 and 2 (resend):
	fix following message at device registration:
	(unregistered net_device): features changed: 0x00011065 -> 0x00015065

patches 3 and 4:
	implement compatibility fallback in ethtool_{g,s}features for drivers
	not converted to new offload setting scheme.

only compile tested for now as my test box has some hardware issues lat=
ely.

best regards,
micha=C5=82 miros=C5=82aw

micha=C5=82 Miros=C5=82aw (4):
  Fix "(unregistered net_device): Features changed" message
  net: avoid initial "Features changed" message
  net: Fix ETHTOOL_GFEATURES compatibility
  net: Implement SFEATURES compatibility for not updated drivers

 include/linux/ethtool.h |    5 +++
 net/core/dev.c          |   12 ++++---
 net/core/ethtool.c      |   75 +++++++++++++++++++++++++++++++++++++++=
++++++++
 3 files changed, 87 insertions(+), 5 deletions(-)

--=20
1.7.2.3

