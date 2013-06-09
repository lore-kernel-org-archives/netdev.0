From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [PATCH net-next] net: ipv6: ping_v6_seq_show() can be static
Date: Sun, 9 Jun 2013 20:28:56 +0800
Message-ID: <20130609122856.GA3166@localhost>
References: <20130609122426.GA2715@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:3333 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753844Ab3FINFY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Jun 2013 09:05:24 -0400
Content-Disposition: inline
In-Reply-To: <20130609122426.GA2715@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TO: Lorenzo Colitti <lorenzo@google.com>
CC: netdev@vger.kernel.org 
CC: linux-kernel@vger.kernel.org 

Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 net/ipv6/ping.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Sorry I just realized this patch could be folded into the previous
one.. It was two patches because the problems are found in two times.

--- linux-next.orig/net/ipv6/ping.c	2013-06-09 20:20:11.085728559 +0800
+++ linux-next/net/ipv6/ping.c	2013-06-09 20:25:25.913736041 +0800
@@ -198,7 +198,7 @@ static void *ping_v6_seq_start(struct se
 	return ping_seq_start(seq, pos, AF_INET6);
 }
 
-int ping_v6_seq_show(struct seq_file *seq, void *v)
+static int ping_v6_seq_show(struct seq_file *seq, void *v)
 {
 	if (v == SEQ_START_TOKEN) {
 		seq_puts(seq, IPV6_SEQ_DGRAM_HEADER);
