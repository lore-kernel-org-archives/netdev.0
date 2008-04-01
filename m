From: Ursula Braun <braunu@de.ibm.com>
Subject: [patch 1/3] af_iucv: Use non-deprecated __RW_LOCK_UNLOCKED macro.
Date: Tue, 01 Apr 2008 15:45:22 +0200
Message-ID: <20080401135707.973984000@linux.vnet.ibm.com>
References: <20080401134521.169525000@linux.vnet.ibm.com>
Cc: "Robert P. J. Day" <rpjday@crashcourse.ca>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.de.ibm.com ([195.212.29.157]:13338 "EHLO
	mtagate8.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755092AbYDAN5L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2008 09:57:11 -0400
Content-Disposition: inline; filename=721-afiucv.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert P. J. Day <rpjday@crashcourse.ca>

Signed-off-by: Robert P. J. Day <rpjday@crashcourse.ca>
Signed-off-by: Ursula Braun <braunu@de.ibm.com>
---

 net/iucv/af_iucv.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: net-2.6.26-uschi/net/iucv/af_iucv.c
===================================================================
--- net-2.6.26-uschi.orig/net/iucv/af_iucv.c
+++ net-2.6.26-uschi/net/iucv/af_iucv.c
@@ -53,7 +53,7 @@ static int iucv_callback_connreq(struct 
 static void iucv_callback_connrej(struct iucv_path *, u8 ipuser[16]);
 
 static struct iucv_sock_list iucv_sk_list = {
-	.lock = RW_LOCK_UNLOCKED,
+	.lock = __RW_LOCK_UNLOCKED(iucv_sk_list.lock),
 	.autobind_name = ATOMIC_INIT(0)
 };
 

-- 
