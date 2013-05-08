From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH 0/4] be2net: fixes
Date: Wed, 8 May 2013 17:35:46 +0530
Message-ID: <1368014750-25065-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:57218 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752317Ab3EHMDE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 May 2013 08:03:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pls apply.

Sathya Perla (4):
  be2net: provision VF resources before enabling SR-IOV
  be2net: fix payload_len value for GET_MAC_LIST cmd req
  be2net: fix EQ from getting full while cleaning RX CQ
  be2net: disable TX in be_close()

 drivers/net/ethernet/emulex/benet/be_cmds.c |    5 +--
 drivers/net/ethernet/emulex/benet/be_main.c |   30 ++++++++++++++------------
 2 files changed, 18 insertions(+), 17 deletions(-)
