From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: [PATCH] l2tp: session is an array not a pointer
Date: Thu, 25 Oct 2012 16:22:01 +0100
Message-ID: <20121025152149.17834.24316.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lxorguk.ukuu.org.uk ([81.2.110.251]:53877 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946213Ab2JYPUZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2012 11:20:25 -0400
Received: from localhost.localdomain (earthlight.etchedpixels.co.uk [81.2.110.250])
	by lxorguk.ukuu.org.uk (8.14.5/8.14.1) with ESMTP id q9PFqNVR007774
	for <netdev@vger.kernel.org>; Thu, 25 Oct 2012 16:52:29 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Cox <alan@linux.intel.com>

Signed-off-by: Alan Cox <alan@linux.intel.com>
---

 net/l2tp/l2tp_netlink.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/l2tp/l2tp_netlink.c b/net/l2tp/l2tp_netlink.c
index 6c4cc12..bbba3a1 100644
--- a/net/l2tp/l2tp_netlink.c
+++ b/net/l2tp/l2tp_netlink.c
@@ -632,7 +632,7 @@ static int l2tp_nl_session_send(struct sk_buff *skb, u32 portid, u32 seq, int fl
 	     nla_put_u16(skb, L2TP_ATTR_MRU, session->mru)))
 		goto nla_put_failure;
 
-	if ((session->ifname && session->ifname[0] &&
+	if ((session->ifname[0] &&
 	     nla_put_string(skb, L2TP_ATTR_IFNAME, session->ifname)) ||
 	    (session->cookie_len &&
 	     nla_put(skb, L2TP_ATTR_COOKIE, session->cookie_len,
