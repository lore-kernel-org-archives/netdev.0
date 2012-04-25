From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next 0/7] be2net fixes
Date: Wed, 25 Apr 2012 17:15:52 +0530
Message-ID: <54ea1f39-fd40-40c9-97a4-271ba9e4df49@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:29206 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757737Ab2DYLrK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2012 07:47:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please apply.
Thanks,
Padmanabh

Padmanabh Ratnakar (7):
  be2net: Fix VLAN/multicast packet reception
  be2net: Fix FW download in Lancer
  be2net: Fix ethtool self test for Lancer
  be2net: Fix traffic stall INTx mode
  be2net: Fix Lancer statistics
  be2net: Fix wrong status getting returned for MCC commands
  be2net: Fix FW download for BE

 drivers/net/ethernet/emulex/benet/be.h         |    5 +
 drivers/net/ethernet/emulex/benet/be_cmds.c    |   93 +++++++----
 drivers/net/ethernet/emulex/benet/be_cmds.h    |    8 +-
 drivers/net/ethernet/emulex/benet/be_ethtool.c |    2 +-
 drivers/net/ethernet/emulex/benet/be_hw.h      |   74 ++++++---
 drivers/net/ethernet/emulex/benet/be_main.c    |  221 ++++++++++++++++--------
 6 files changed, 276 insertions(+), 127 deletions(-)
