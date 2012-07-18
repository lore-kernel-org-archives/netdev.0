From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next 0/2] be2net fixes
Date: Wed, 18 Jul 2012 18:21:45 +0530
Message-ID: <9a423faa-bc47-459e-a59b-182dd94b8465@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:29523 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754386Ab2GRMwn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 08:52:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Driver fixes for recent Lancer FW changes.
Please apply.
Thanks,
Padmanabh

Padmanabh Ratnakar (2):
  be2net: Fix VF driver load for Lancer
  be2net: Ignore physical link async event for Lancer

 drivers/net/ethernet/emulex/benet/be_cmds.c |    8 +++++++-
 drivers/net/ethernet/emulex/benet/be_cmds.h |    1 +
 drivers/net/ethernet/emulex/benet/be_main.c |    7 +++++++
 3 files changed, 15 insertions(+), 1 deletions(-)
