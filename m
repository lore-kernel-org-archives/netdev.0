From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH net-next 2/5] sctp: remove the else path
Date: Fri, 8 Nov 2013 10:55:07 +0800
Message-ID: <1383879310-22792-3-git-send-email-wangweidong1@huawei.com>
References: <1383879310-22792-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <dingtianhong@huawei.com>, <davem@davemloft.net>,
	<linux-sctp@vger.kernel.org>, <netdev@vger.kernel.org>
To: <vyasevich@gmail.com>, <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:32232 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756541Ab3KHC4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 21:56:05 -0500
In-Reply-To: <1383879310-22792-1-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make the code more simplification.

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/sctp/associola.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index 667f984..2d53d4c 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -954,15 +954,13 @@ int sctp_cmp_addr_exact(const union sctp_addr *ss1,
  */
 struct sctp_chunk *sctp_get_ecne_prepend(struct sctp_association *asoc)
 {
-	struct sctp_chunk *chunk;
+	struct sctp_chunk *chunk = NULL;
 
 	/* Send ECNE if needed.
 	 * Not being able to allocate a chunk here is not deadly.
 	 */
 	if (asoc->need_ecne)
 		chunk = sctp_make_ecne(asoc, asoc->last_ecne_tsn);
-	else
-		chunk = NULL;
 
 	return chunk;
 }
-- 
1.7.12
