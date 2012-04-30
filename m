From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH net-next 0/5] be2net fixes
Date: Mon, 30 Apr 2012 11:33:47 +0530
Message-ID: <ef51171e-d498-4201-b836-db6fbdb2ee4f@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Somnath Kotur <somnath.kotur@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:42944 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751012Ab2D3GFH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2012 02:05:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Re-posting patches after incorporating Ben Hutchings's 
review comments in patches 2 and one of the comments for patch 5

Somnath Kotur (5):
  be2net: Fix to not set link speed for disabled functions of a UMC
    card
  be2net: Fix to apply duplex value as unknown when link is down.
  be2net: Record receive queue index in skb to aid RPS.
  be2net: Fix EEH error reset before a flash dump completes
  be2net: Fix to allow set/get of debug levels in the Firmware.

 drivers/net/ethernet/emulex/benet/be_cmds.c    |   60 +++++++++++++
 drivers/net/ethernet/emulex/benet/be_cmds.h    |   70 +++++++++++++++
 drivers/net/ethernet/emulex/benet/be_ethtool.c |  112 +++++++++++++++++++++++-
 drivers/net/ethernet/emulex/benet/be_main.c    |    7 ++
 4 files changed, 247 insertions(+), 2 deletions(-)
