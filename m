From: yuan linyu <cugyly@163.com>
Subject: [PATCH net-next 09/11] sctp: skb_put_zero() used to optimize code
Date: Wed, 14 Jun 2017 22:57:43 +0800
Message-ID: <1497452263-5032-1-git-send-email-cugyly@163.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-18.163.com ([220.181.12.18]:59778 "EHLO m12-18.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751065AbdFNO6S (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Jun 2017 10:58:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>

Signed-off-by: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
---
 net/sctp/output.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sctp/output.c b/net/sctp/output.c
index e2edf2e..c339c68 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -463,7 +463,7 @@ static int sctp_packet_pack(struct sctp_packet *packet,
 
 			padding = SCTP_PAD4(chunk->skb->len) - chunk->skb->len;
 			if (padding)
-				memset(skb_put(chunk->skb, padding), 0, padding);
+				skb_put_zero(chunk->skb, padding);
 
 			if (chunk == packet->auth)
 				auth = (struct sctp_auth_chunk *)
-- 
2.7.4
