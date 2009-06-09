From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 8/8] qlge: bugfix: Get rid of errant spin_unlock().
Date: Tue,  9 Jun 2009 08:39:34 -0700
Message-ID: <1244561974-25662-8-git-send-email-ron.mercer@qlogic.com>
References: <1244561974-25662-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:58941 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753662AbZFIPrT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 11:47:19 -0400
In-Reply-To: <1244561974-25662-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)
 mode change 100644 => 100755 drivers/net/qlge/qlge_main.c

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
old mode 100644
new mode 100755
index 5055f5b..024c734
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -3299,7 +3299,6 @@ static int ql_adapter_up(struct ql_adapter *qdev)
 	err = ql_adapter_initialize(qdev);
 	if (err) {
 		QPRINTK(qdev, IFUP, INFO, "Unable to initialize adapter.\n");
-		spin_unlock(&qdev->hw_lock);
 		goto err_init;
 	}
 	set_bit(QL_ADAPTER_UP, &qdev->flags);
-- 
1.6.0.2

