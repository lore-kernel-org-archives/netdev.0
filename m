From: Alexey Dobriyan <adobriyan@sw.ru>
Subject: [PATCH] Copy mac_len in skb_clone() as well
Date: Wed, 14 Mar 2007 16:07:11 +0300
Message-ID: <20070314130711.GA6812@localhost.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, devel@openvz.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:32758 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161255AbXCNNAD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Mar 2007 09:00:03 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ANK says: "It is rarely used, that's wy it was not noticed.
But in the places, where it is used, it should be disaster."

Signed-off-by: Alexey Dobriyan <adobriyan@sw.ru>
---

 net/core/skbuff.c |    1 +
 1 file changed, 1 insertion(+)

--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -463,6 +463,7 @@ #endif
 	memcpy(n->cb, skb->cb, sizeof(skb->cb));
 	C(len);
 	C(data_len);
+	C(mac_len);
 	C(csum);
 	C(local_df);
 	n->cloned = 1;

