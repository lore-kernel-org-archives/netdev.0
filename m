From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH net-next] sctp: remove the unnecessary assignment
Date: Thu, 16 Jan 2014 16:25:19 +0800
Message-ID: <52D7976F.7070708@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-sctp@vger.kernel.org>
To: Neil Horman <nhorman@tuxdriver.com>,
	David Miller <davem@davemloft.net>,
	Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:33092 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750960AbaAPI0E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 03:26:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When go the right path, the status is 0, no need to assign it again.
So just remove the assignment.

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/sctp/protocol.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 7c16108..d6934dc 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -1461,7 +1461,6 @@ static __init int sctp_init(void)
 	if (status)
 		goto err_v6_add_protocol;
 
-	status = 0;
 out:
 	return status;
 err_v6_add_protocol:
-- 
1.7.12
