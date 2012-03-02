From: santosh nayak <santoshprasadnayak@gmail.com>
Subject: [PATCH 2/3] qla3xxx: ethernet: Silence static checker warning.
Date: Fri,  2 Mar 2012 20:39:39 +0530
Message-ID: <1330700979-18231-1-git-send-email-santoshprasadnayak@gmail.com>
Cc: ron.mercer@qlogic.com, linux-driver@qlogic.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org,
	Santosh Nayak <santoshprasadnayak@gmail.com>
To: jitendra.kalsaria@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:45493 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758538Ab2CBPKb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Mar 2012 10:10:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Santosh Nayak <santoshprasadnayak@gmail.com>

Silence the following warning:
"warn: returning -1 instead of -ENOMEM is sloppy".

Signed-off-by: Santosh Nayak <santoshprasadnayak@gmail.com>
---
 drivers/net/ethernet/qlogic/qla3xxx.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qla3xxx.c b/drivers/net/ethernet/qlogic/qla3xxx.c
index 8da3e41..df09b1c 100644
--- a/drivers/net/ethernet/qlogic/qla3xxx.c
+++ b/drivers/net/ethernet/qlogic/qla3xxx.c
@@ -2836,7 +2836,7 @@ static int ql_create_send_free_list(struct ql3_adapter *qdev)
 		req_q_curr++;
 		tx_cb->oal = kmalloc(512, GFP_KERNEL);
 		if (tx_cb->oal == NULL)
-			return -1;
+			return -ENOMEM;
 	}
 	return 0;
 }
-- 
1.7.4.4
