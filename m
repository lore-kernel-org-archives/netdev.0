From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 4/8] qlge: Store firmware revision as early as possible.
Date: Sat, 10 Oct 2009 12:35:06 -0700
Message-ID: <1255203310-18114-5-git-send-email-ron.mercer@qlogic.com>
References: <1255203310-18114-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:55225 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934751AbZJJTmo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Oct 2009 15:42:44 -0400
In-Reply-To: <1255203310-18114-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_mpi.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qlge/qlge_mpi.c b/drivers/net/qlge/qlge_mpi.c
index 2e83c4b..9c0dfe0 100644
--- a/drivers/net/qlge/qlge_mpi.c
+++ b/drivers/net/qlge/qlge_mpi.c
@@ -317,6 +317,7 @@ static void ql_init_fw_done(struct ql_adapter *qdev, struct mbox_params *mbcp)
 	} else {
 		QPRINTK(qdev, DRV, ERR, "Firmware Revision  = 0x%.08x.\n",
 			mbcp->mbox_out[1]);
+		qdev->fw_rev_id = mbcp->mbox_out[1];
 		status = ql_cam_route_initialize(qdev);
 		if (status)
 			QPRINTK(qdev, IFUP, ERR,
-- 
1.6.0.2

