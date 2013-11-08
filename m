From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH net-next v2 4/4] sctp: fix some comments in associola.c
Date: Fri, 8 Nov 2013 14:17:51 +0800
Message-ID: <1383891471-20892-5-git-send-email-wangweidong1@huawei.com>
References: <1383891471-20892-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <dingtianhong@huawei.com>,
	<linux-sctp@vger.kernel.org>, <netdev@vger.kernel.org>
To: <vyasevich@gmail.com>, <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:61502 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750828Ab3KHGSh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 01:18:37 -0500
In-Reply-To: <1383891471-20892-1-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fix some typos

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/sctp/associola.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index 8dab0bf..b96b771 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -128,7 +128,7 @@ static struct sctp_association *sctp_association_init(struct sctp_association *a
 	 */
 	asoc->param_flags = sp->param_flags;
 
-	/* Initialize the maximum mumber of new data packets that can be sent
+	/* Initialize the maximum number of new data packets that can be sent
 	 * in a burst.
 	 */
 	asoc->max_burst = sp->max_burst;
@@ -231,7 +231,7 @@ static struct sctp_association *sctp_association_init(struct sctp_association *a
 
 	/* Assume that the peer will tell us if he recognizes ASCONF
 	 * as part of INIT exchange.
-	 * The sctp_addip_noauth option is there for backward compatibilty
+	 * The sctp_addip_noauth option is there for backward compatibility
 	 * and will revert old behavior.
 	 */
 	if (net->sctp.addip_noauth)
@@ -1221,7 +1221,7 @@ void sctp_assoc_update(struct sctp_association *asoc,
 		}
 	}
 
-	/* SCTP-AUTH: Save the peer parameters from the new assocaitions
+	/* SCTP-AUTH: Save the peer parameters from the new associations
 	 * and also move the association shared keys over
 	 */
 	kfree(asoc->peer.peer_random);
@@ -1446,7 +1446,7 @@ void sctp_assoc_rwnd_decrease(struct sctp_association *asoc, unsigned int len)
 
 	/* If we've reached or overflowed our receive buffer, announce
 	 * a 0 rwnd if rwnd would still be positive.  Store the
-	 * the pottential pressure overflow so that the window can be restored
+	 * the potential pressure overflow so that the window can be restored
 	 * back to original value.
 	 */
 	if (rx_count >= asoc->base.sk->sk_rcvbuf)
-- 
1.7.12
