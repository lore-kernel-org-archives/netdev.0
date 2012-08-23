From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [PATCH] af_packet: match_fanout_group() can be static
Date: Thu, 23 Aug 2012 19:51:21 +0800
Message-ID: <20120823115121.GA17472@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: networking <netdev@vger.kernel.org>, Eric Leblond <eric@regit.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:63733 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752089Ab2HWLv3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Aug 2012 07:51:29 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

cc: Eric Leblond <eric@regit.org>
Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 net/packet/af_packet.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-next.orig/net/packet/af_packet.c	2012-08-23 19:48:43.209188551 +0800
+++ linux-next/net/packet/af_packet.c	2012-08-23 19:48:53.413188794 +0800
@@ -1273,7 +1273,7 @@ static void __fanout_unlink(struct sock
 	spin_unlock(&f->lock);
 }
 
-bool match_fanout_group(struct packet_type *ptype, struct sock * sk)
+static bool match_fanout_group(struct packet_type *ptype, struct sock * sk)
 {
 	if (ptype->af_packet_priv == (void*)((struct packet_sock *)sk)->fanout)
 		return true;
