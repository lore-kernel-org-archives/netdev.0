From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH 6/6] net: fix kernel-doc warning in core/filter.c
Date: Sat, 8 Jan 2011 19:41:42 -0800
Message-ID: <20110108194142.22a0c3d8.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linus <torvalds@linux-foundation.org>, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:57816 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751114Ab1AIDpf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Jan 2011 22:45:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

Fix new kernel-doc notation warning in net/core/filter.c:

Warning(net/core/filter.c:172): No description found for parameter 'fentry'
Warning(net/core/filter.c:172): Excess function parameter 'filter' description in 'sk_run_filter'

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 net/core/filter.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- lnx0107.orig/net/core/filter.c
+++ lnx0107/net/core/filter.c
@@ -158,7 +158,7 @@ EXPORT_SYMBOL(sk_filter);
 /**
  *	sk_run_filter - run a filter on a socket
  *	@skb: buffer to run the filter on
- *	@filter: filter to apply
+ *	@fentry: filter to apply
  *
  * Decode and apply filter instructions to the skb->data.
  * Return length to keep, 0 for none. @skb is the data we are
