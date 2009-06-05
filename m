From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH net-next 3/3] tun: Fix copy/paste error in tun_get_user
Date: Fri, 05 Jun 2009 12:35:46 -0700
Message-ID: <1244230546.1526.78.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org, mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:60279 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752016AbZFETfq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Jun 2009 15:35:46 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n55JVYI2029867
	for <netdev@vger.kernel.org>; Fri, 5 Jun 2009 15:31:34 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n55JZmul222724
	for <netdev@vger.kernel.org>; Fri, 5 Jun 2009 15:35:48 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n55JZmrb029223
	for <netdev@vger.kernel.org>; Fri, 5 Jun 2009 15:35:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the right structure while incrementing the offset in tun_get_user.

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 4cda69b..15cfcb2 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -567,7 +567,7 @@ static __inline__ ssize_t tun_get_user(struct
tun_struct *tun,

 		if (gso.hdr_len > len)
 			return -EINVAL;
-		offset += sizeof(pi);
+		offset += sizeof(gso);
 	}

 	if ((tun->flags & TUN_TYPE_MASK) == TUN_TAP_DEV) {


