From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH net-next 0/4] be2net fixes
Date: Wed, 2 May 2012 19:09:46 +0530
Message-ID: <88a38ad8-0db5-47cb-a868-59e13a8f746d@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Somnath Kotur <somnath.kotur@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:19197 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752127Ab2EBNlI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2012 09:41:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Re-posting patches 1-4 from the earlier patch set of 5.
Incorporated review comment from Ben Hutchings in patch 2.
Will address comments in Patch 5 and send it out seperately.

Somnath Kotur (4):
  be2net: Fix to not set link speed for disabled functions of a UMC
    card
  be2net: Fix to apply duplex value as unknown when link is down.
  be2net: Record receive queue index in skb to aid RPS.
  be2net: Fix EEH error reset before a flash dump completes

 drivers/net/ethernet/emulex/benet/be_ethtool.c |    4 ++--
 drivers/net/ethernet/emulex/benet/be_main.c    |    7 +++++++
 2 files changed, 9 insertions(+), 2 deletions(-)
