From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 1/5] isdn/gigaset: drop duplicate declaration
Date: Wed, 10 Dec 2014 13:41:55 +0100 (CET)
Message-ID: <a2f1fce1fd56249def24faf0cd6767fe66bdb0dd.1418214588.git.tilman@imap.cc>
References: <cover.1418214588.git.tilman@imap.cc>
Cc: David Miller <davem@davemloft.net>, Hansjoerg Lipp <hjlipp@web.de>,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gimli.pxnet.com ([89.1.7.7]:33187 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755578AbaLJM7z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Dec 2014 07:59:55 -0500
In-Reply-To: <cover.1418214588.git.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Function gigaset_skb_sent was declared twice, identically, in gigaset.h.

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/gigaset.h | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/isdn/gigaset/gigaset.h b/drivers/isdn/gigaset/gigaset.h
index eb63a0f..166537e 100644
--- a/drivers/isdn/gigaset/gigaset.h
+++ b/drivers/isdn/gigaset/gigaset.h
@@ -751,9 +751,6 @@ void gigaset_stop(struct cardstate *cs);
 /* Tell common.c that the driver is being unloaded. */
 int gigaset_shutdown(struct cardstate *cs);
 
-/* Tell common.c that an skb has been sent. */
-void gigaset_skb_sent(struct bc_state *bcs, struct sk_buff *skb);
-
 /* Append event to the queue.
  * Returns NULL on failure or a pointer to the event on success.
  * ptr must be kmalloc()ed (and not be freed by the caller).
-- 
1.9.2.459.g68773ac
