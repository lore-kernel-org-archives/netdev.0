From: Zhi Yong Wu <zwu.kernel@gmail.com>
Subject: [PATCH 2/3] net, datagram: fix the uncorrect comment in zerocopy_sg_from_iovec()
Date: Fri, 25 Oct 2013 15:49:19 +0800
Message-ID: <1382687360-27794-2-git-send-email-zwu.kernel@gmail.com>
References: <1382687360-27794-1-git-send-email-zwu.kernel@gmail.com>
Cc: linux-kernel@vger.kernel.org,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:57542 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751421Ab3JYHvZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Oct 2013 03:51:25 -0400
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <zwu.kernel@gmail.com>;
	Fri, 25 Oct 2013 01:51:24 -0600
In-Reply-To: <1382687360-27794-1-git-send-email-zwu.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>

Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
---
 net/core/datagram.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/datagram.c b/net/core/datagram.c
index af814e7..a16ed7b 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -577,7 +577,7 @@ EXPORT_SYMBOL(skb_copy_datagram_from_iovec);
 /**
  *	zerocopy_sg_from_iovec - Build a zerocopy datagram from an iovec
  *	@skb: buffer to copy
- *	@from: io vector to copy to
+ *	@from: io vector to copy from
  *	@offset: offset in the io vector to start copying from
  *	@count: amount of vectors to copy to buffer from
  *
-- 
1.7.11.7
