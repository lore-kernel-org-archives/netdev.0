From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH net-next 4/4] sctp: fix comment in chunk.c
Date: Fri, 25 Oct 2013 11:45:48 +0800
Message-ID: <1382672748-10156-5-git-send-email-wangweidong1@huawei.com>
References: <1382672748-10156-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <dingtianhong@huawei.com>,
	<linux-sctp@vger.kernel.org>, <netdev@vger.kernel.org>
To: <nhorman@tuxdriver.com>, <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:41443 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755760Ab3JYDqn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 23:46:43 -0400
In-Reply-To: <1382672748-10156-1-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fix a spelling

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/sctp/chunk.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sctp/chunk.c b/net/sctp/chunk.c
index 7bd5ed4..f2044fc 100644
--- a/net/sctp/chunk.c
+++ b/net/sctp/chunk.c
@@ -201,7 +201,7 @@ struct sctp_datamsg *sctp_datamsg_from_user(struct sctp_association *asoc,
 
 	max = asoc->frag_point;
 	/* If the the peer requested that we authenticate DATA chunks
-	 * we need to accound for bundling of the AUTH chunks along with
+	 * we need to account for bundling of the AUTH chunks along with
 	 * DATA.
 	 */
 	if (sctp_auth_send_cid(SCTP_CID_DATA, asoc)) {
-- 
1.7.12
