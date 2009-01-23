From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 08/21] [next] qlge: Move interrupt enable to end of adapter up function.
Date: Fri, 23 Jan 2009 07:16:26 -0800
Message-ID: <1232723799-8620-8-git-send-email-ron.mercer@qlogic.com>
References: <20090123151513.GA8526@linux-ox1b.qlogic.org>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:48587 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754164AbZAWPRt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2009 10:17:49 -0500
In-Reply-To: <20090123151513.GA8526@linux-ox1b.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 97b72a6..f273160 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -3200,10 +3200,10 @@ static int ql_adapter_up(struct ql_adapter *qdev)
 		goto err_init;
 	}
 	set_bit(QL_ADAPTER_UP, &qdev->flags);
-	ql_enable_interrupts(qdev);
 	ql_enable_all_completion_interrupts(qdev);
 	if ((ql_read32(qdev, STS) & qdev->port_init))
 		ql_link_on(qdev);
+	ql_enable_interrupts(qdev);
 	return 0;
 err_init:
 	ql_adapter_reset(qdev);
-- 
1.6.0.2

