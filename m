From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch -next] l2tp: calling the ref() instead of deref()
Date: Fri, 22 Mar 2013 21:33:15 +0300
Message-ID: <20130322183314.GA23163@longonot.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Chapman <jchapman@katalix.com>,
	Tom Parkin <tparkin@katalix.com>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org, kbuild@01.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:19891 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754499Ab3CVSgQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Mar 2013 14:36:16 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a cut and paste typo.  We call ->ref() a second time instead
of ->deref().

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
Only needed in linux-next.

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index 8aecf5d..6984c3a 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -1777,7 +1777,7 @@ int l2tp_session_delete(struct l2tp_session *session)
 	if (session->session_close != NULL)
 		(*session->session_close)(session);
 	if (session->deref)
-		(*session->ref)(session);
+		(*session->deref)(session);
 	l2tp_session_dec_refcount(session);
 	return 0;
 }
