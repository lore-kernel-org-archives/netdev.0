From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] bnx2x: remove some dead code
Date: Wed, 5 Oct 2011 08:49:18 +0300
Message-ID: <20111005054918.GC32077@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Eilon Greenstein <eilong@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:42347 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932862Ab1JEFtZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2011 01:49:25 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This code is after the break statement so it never gets used.  The
"vlan_mac_obj" variable does get initialized properly, so we can just
delete this.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 04f17a1..6486ab8 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -4353,8 +4353,6 @@ static inline void bnx2x_handle_classification_eqe(struct bnx2x *bp,
 			vlan_mac_obj = &bp->fp[cid].mac_obj;
 
 		break;
-		vlan_mac_obj = &bp->fp[cid].mac_obj;
-
 	case BNX2X_FILTER_MCAST_PENDING:
 		/* This is only relevant for 57710 where multicast MACs are
 		 * configured as unicast MACs using the same ramrod.
