From: Roland Dreier <rdreier@cisco.com>
Subject: [PATCH 3/4] ibm_new_emac: Nuke SET_MODULE_OWNER() use
Date: Tue, 09 Oct 2007 15:47:59 -0700
Message-ID: <ada4pgzhpls.fsf_-_@cisco.com>
References: <OF20E88706.D91FCF10-ON6525736F.003E50CD-6525736F.003E5E6F@in.ibm.com>
	<20071009.042441.30182968.davem@davemloft.net>
	<ada3awkhwbv.fsf@cisco.com>
	<20071009.135145.95506679.davem@davemloft.net>
	<adahckzhprc.fsf@cisco.com> <adad4vnhpoq.fsf_-_@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, general@lists.openfabrics.org,
	jeff@garzik.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:4024 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753482AbXJIWsA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 18:48:00 -0400
In-Reply-To: <adad4vnhpoq.fsf_-_@cisco.com> (Roland Dreier's message of "Tue, 09 Oct 2007 15:46:13 -0700")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Roland Dreier <rolandd@cisco.com>
---
 drivers/net/ibm_newemac/core.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ibm_newemac/core.c b/drivers/net/ibm_newemac/core.c
index ce127b9..8ea5009 100644
--- a/drivers/net/ibm_newemac/core.c
+++ b/drivers/net/ibm_newemac/core.c
@@ -2549,7 +2549,6 @@ static int __devinit emac_probe(struct of_device *ofdev,
 	dev->ndev = ndev;
 	dev->ofdev = ofdev;
 	dev->blist = blist;
-	SET_MODULE_OWNER(ndev);
 	SET_NETDEV_DEV(ndev, &ofdev->dev);
 
 	/* Initialize some embedded data structures */
