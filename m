From: Sathya Perla <sathya.perla@emulex.com>
Subject: [net-next PATCH 0/4] fixes v2
Date: Fri, 28 Sep 2012 20:09:40 +0530
Message-ID: <6f10c564-0b2c-4d31-97a1-cf894c883cbb@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sathya Perla <sathya.perla@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:49342 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758343Ab2I1PDY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2012 11:03:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Resending the patch series minus the patch to remove the AMAP macros.
Pls apply.

Sathya Perla (4):
  be2net: remove type argument of be_cmd_mac_addr_query()
  be2net: fix wrong handling of be_setup() failure in be_probe()
  be2net: cleanup code related to be_link_status_query()
  be2net: fixup log messages

 drivers/net/ethernet/emulex/benet/be.h         |    1 -
 drivers/net/ethernet/emulex/benet/be_cmds.c    |   53 +++++++++++++++------
 drivers/net/ethernet/emulex/benet/be_cmds.h    |    6 +-
 drivers/net/ethernet/emulex/benet/be_ethtool.c |   57 +++++------------------
 drivers/net/ethernet/emulex/benet/be_main.c    |   60 ++++++++++++++---------
 5 files changed, 89 insertions(+), 88 deletions(-)

-- 
1.7.4
