From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 3/8] qlge: Add handler for DCBX firmware event.
Date: Sat, 10 Oct 2009 12:35:05 -0700
Message-ID: <1255203310-18114-4-git-send-email-ron.mercer@qlogic.com>
References: <1255203310-18114-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:55225 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934780AbZJJTm3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Oct 2009 15:42:29 -0400
In-Reply-To: <1255203310-18114-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver has nothing to do, but this marker prevents the event from
showing up 'not handled'.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_mpi.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qlge/qlge_mpi.c b/drivers/net/qlge/qlge_mpi.c
index 99e58e3..2e83c4b 100644
--- a/drivers/net/qlge/qlge_mpi.c
+++ b/drivers/net/qlge/qlge_mpi.c
@@ -446,6 +446,9 @@ static int ql_mpi_handler(struct ql_adapter *qdev, struct mbox_params *mbcp)
 		ql_aen_lost(qdev, mbcp);
 		break;
 
+	case AEN_DCBX_CHG:
+		/* Need to support AEN 8110 */
+		break;
 	default:
 		QPRINTK(qdev, DRV, ERR,
 			"Unsupported AE %.08x.\n", mbcp->mbox_out[0]);
-- 
1.6.0.2

