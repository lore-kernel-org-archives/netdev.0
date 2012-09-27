From: Sathya Perla <sathya.perla@emulex.com>
Subject: [net-next PATCH 0/5] be2net: fixes
Date: Thu, 27 Sep 2012 12:02:43 +0530
Message-ID: <bbf75b2d-3e65-4ee5-a8d1-d8b4a70c496d@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sathya Perla <sathya.perla@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:17099 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754831Ab2I0G4T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2012 02:56:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pls apply. Thanks.

Sathya Perla (5):
  be2net: remove type argument of be_cmd_mac_addr_query()
  be2net: fix wrong handling of be_setup() failure in be_probe()
  be2net: cleanup code related to be_link_status_query()
  be2net: get rid of AMAP_SET/GET macros in TX path
  be2net: fixup log messages

 drivers/net/ethernet/emulex/benet/be.h         |    1 -
 drivers/net/ethernet/emulex/benet/be_cmds.c    |   53 ++++++++---
 drivers/net/ethernet/emulex/benet/be_cmds.h    |    6 +-
 drivers/net/ethernet/emulex/benet/be_ethtool.c |   57 +++---------
 drivers/net/ethernet/emulex/benet/be_hw.h      |   62 ++++---------
 drivers/net/ethernet/emulex/benet/be_main.c    |  118 ++++++++++++------------
 6 files changed, 130 insertions(+), 167 deletions(-)

-- 
1.7.4
