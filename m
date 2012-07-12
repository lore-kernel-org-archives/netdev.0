From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next 0/7] be2net updates
Date: Thu, 12 Jul 2012 19:25:01 +0530
Message-ID: <a8f2c513-d398-4be6-a059-242dfc2c052a@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:49168 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161101Ab2GLOBU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 10:01:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please apply.
Thanks,
Padmanabh

Padmanabh Ratnakar (7):
  be2net: Fix error while toggling autoneg of pause parameters
  be2net : Fix die temperature stat for Lancer
  be2net: Fix initialization sequence for Lancer
  be2net: Activate new FW after FW download for Lancer
  be2net: Fix cleanup path when EQ creation fails
  be2net: Fix port name in message during driver load
  be2net: Enable RSS UDP hashing for Lancer and Skyhawk

 drivers/net/ethernet/emulex/benet/be.h         |   24 ++-
 drivers/net/ethernet/emulex/benet/be_cmds.c    |  142 +++++++++++-
 drivers/net/ethernet/emulex/benet/be_cmds.h    |   34 +++-
 drivers/net/ethernet/emulex/benet/be_ethtool.c |    2 +-
 drivers/net/ethernet/emulex/benet/be_hw.h      |    7 +-
 drivers/net/ethernet/emulex/benet/be_main.c    |  291 +++++++++++++-----------
 6 files changed, 345 insertions(+), 155 deletions(-)
