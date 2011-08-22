From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 0/5] be2net: fixes
Date: Mon, 22 Aug 2011 16:43:28 +0530
Message-ID: <1314011613-4519-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:12581 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756809Ab1HVLOT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2011 07:14:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pls apply.

Sathya Perla (5):
  be2net: Fix race in posting rx buffers.
  be2net: get rid of memory mapped pci-cfg space address
  be2net: fix erx->rx_drops_no_frags wrap around
  be2net: increase FW update completion timeout
  be2net: remove unused variable

 drivers/net/ethernet/emulex/benet/be.h      |    2 -
 drivers/net/ethernet/emulex/benet/be_cmds.c |    2 +-
 drivers/net/ethernet/emulex/benet/be_main.c |   50 ++++++++++++++------------
 3 files changed, 28 insertions(+), 26 deletions(-)

-- 
1.7.4

