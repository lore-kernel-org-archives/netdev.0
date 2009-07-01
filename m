From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 2/2] gigaset: drop pointless check
Date: Wed,  1 Jul 2009 23:20:57 +0200 (CEST)
Message-ID: <20090701-patch-02.tilman@imap.cc>
References: <20090701-patch-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>
To: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gimli.pxnet.com ([195.227.45.7]:49491 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752809AbZGAVVH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Jul 2009 17:21:07 -0400
In-Reply-To: <20090701-patch-00.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Drop a sanity check which doesn't serve any useful purpose anymore.

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/isocdata.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/drivers/isdn/gigaset/isocdata.c b/drivers/isdn/gigaset/isocdata.c
index db3a1e4..bed38fc 100644
--- a/drivers/isdn/gigaset/isocdata.c
+++ b/drivers/isdn/gigaset/isocdata.c
@@ -174,12 +174,6 @@ int gigaset_isowbuf_getbytes(struct isowbuf_t *iwb, int size)
 		pr_err("invalid size %d\n", size);
 		return -EINVAL;
 	}
-	src = iwb->read;
-	if (unlikely(limit >= BAS_OUTBUFSIZE + BAS_OUTBUFPAD ||
-		     (read < src && limit >= src))) {
-		pr_err("isoc write buffer frame reservation violated\n");
-		return -EFAULT;
-	}
 #endif
 
 	if (read < write) {
-- 
1.6.2.1.214.ge986c

