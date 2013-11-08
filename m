From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH net-next 5/5] sctp: fix some typos in associola.c
Date: Fri, 8 Nov 2013 10:55:10 +0800
Message-ID: <1383879310-22792-6-git-send-email-wangweidong1@huawei.com>
References: <1383879310-22792-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <dingtianhong@huawei.com>, <davem@davemloft.net>,
	<linux-sctp@vger.kernel.org>, <netdev@vger.kernel.org>
To: <vyasevich@gmail.com>, <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:32114 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756311Ab3KHCzy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 21:55:54 -0500
In-Reply-To: <1383879310-22792-1-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fix some typos

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/sctp/associola.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index c6cfff6..fadf31d 100644
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
@@ -1227,7 +1227,7 @@ void sctp_assoc_update(struct sctp_association *asoc,
 	if (new->ssnmap)
 		sctp_ssnmap_free(new->ssnmap);
 
-	/* SCTP-AUTH: Save the peer parameters from the new assocaitions
+	/* SCTP-AUTH: Save the peer parameters from the new associations
 	 * and also move the association shared keys over
 	 */
 	kfree(asoc->peer.peer_random);
@@ -1452,7 +1452,7 @@ void sctp_assoc_rwnd_decrease(struct sctp_association *asoc, unsigned int len)
 
 	/* If we've reached or overflowed our receive buffer, announce
 	 * a 0 rwnd if rwnd would still be positive.  Store the
-	 * the pottential pressure overflow so that the window can be restored
+	 * the potential pressure overflow so that the window can be restored
 	 * back to original value.
 	 */
 	if (rx_count >= asoc->base.sk->sk_rcvbuf)
-- 
1.7.12
