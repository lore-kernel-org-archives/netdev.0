From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 0/7] be2net: patch series
Date: Wed, 6 Jun 2012 11:09:20 +0530
Message-ID: <9df87e5c-acca-4dce-82b6-ab42dfe7114d@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sathya Perla <sathya.perla@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:2048 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753871Ab2FFFyZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2012 01:54:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pls apply.

Sathya Perla (7):
  be2net: do not call be_vid_config() when there's no vlan config
  be2net: cleanup be_vid_config()
  be2net: do not modify PCI MaxReadReq size
  be2net: fix reporting number of actual rx queues
  be2net: remove unnecessary usage of unlikely()
  be2net: do not use SCRATCHPAD register
  be2net: update driver version

 drivers/net/ethernet/emulex/benet/be.h      |    2 +-
 drivers/net/ethernet/emulex/benet/be_hw.h   |    2 -
 drivers/net/ethernet/emulex/benet/be_main.c |   50 ++++++++++++---------------
 3 files changed, 23 insertions(+), 31 deletions(-)

-- 
1.7.4
