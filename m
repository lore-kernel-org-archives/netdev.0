From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next 0/5] be2net updates
Date: Fri, 25 Nov 2011 21:17:10 +0530
Message-ID: <2a52fa80-d1de-450f-976e-67774fdc5347@exht2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht2.emulex.com ([138.239.113.184]:44947 "EHLO
	exht2.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753074Ab1KYPsP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2011 10:48:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please apply.
Thanks,
Padmanabh

Padmanabh Ratnakar (5):
  be2net: Move to new SR-IOV implementation in Lancer
  be2net: Fix error recovery paths
  be2net: Add error handling for Lancer
  be2net: Use new hash key
  be2net: Fix non utilization of RX queues

 drivers/net/ethernet/emulex/benet/be_cmds.c |  104 ++++++++++-
 drivers/net/ethernet/emulex/benet/be_cmds.h |   37 ++++-
 drivers/net/ethernet/emulex/benet/be_main.c |  265 +++++++++++++++++++--------
 3 files changed, 323 insertions(+), 83 deletions(-)
