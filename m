From: Somnath Kotur <Somnath.Kotur@emulex.com>
Subject: [PATCH net-next 0/5] be2net fixes
Date: Thu, 26 Apr 2012 19:57:14 +0530
Message-ID: <9029d129-fbaa-4d4c-b3f0-4268da3ba1b0@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Somnath Kotur <somnath.kotur@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:47275 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753184Ab2DZOhA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2012 10:37:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Somnath Kotur <somnath.kotur@emulex.com>

Please apply.

Thanks
Somnath

Somnath Kotur (5):
  be2net: Fix to not set link speed for disabled functions of a UMC
    card
  be2net: Fix to allow setting of debug levels in the firmware.
  be2net: Fix to apply duplex value as unknown when link is down.
  be2net: Record receive queue index in skb to aid RPS.
  be2net: Fix EEH error reset before a flash dump completes

 drivers/net/ethernet/emulex/benet/be_cmds.c    |   59 ++++++++++++++++++++
 drivers/net/ethernet/emulex/benet/be_cmds.h    |   69 +++++++++++++++++++++++
 drivers/net/ethernet/emulex/benet/be_ethtool.c |   71 +++++++++++++++++++++++-
 drivers/net/ethernet/emulex/benet/be_main.c    |    7 ++
 4 files changed, 204 insertions(+), 2 deletions(-)
