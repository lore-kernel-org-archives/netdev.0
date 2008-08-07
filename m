From: jamal <hadi@cyberus.ca>
Subject: [PATCH] wext: Send name on events
Date: Thu, 07 Aug 2008 09:25:15 -0400
Message-ID: <1218115515.4735.3.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-jF+ZTBye8ajLfqtqVjI+"
Cc: netdev@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.28]:56510 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751515AbYHGNZe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2008 09:25:34 -0400
Received: by yx-out-2324.google.com with SMTP id 8so111402yxm.1
        for <netdev@vger.kernel.org>; Thu, 07 Aug 2008 06:25:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-jF+ZTBye8ajLfqtqVjI+
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


iproute2 doesnt like it, so i was getting irritated by this on my
laptop. 

cheers,
jamal

--=-jF+ZTBye8ajLfqtqVjI+
Content-Disposition: attachment; filename=wext-1
Content-Type: text/plain; name=wext-1; charset=us-ascii
Content-Transfer-Encoding: 7bit

wext: Send name on events

In the minimal the wireless extensions oughta send at least
the name in addition to the ifindex.

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

---
commit 8dd4c21ea0029bb6a9c838254460f9b1ca677531
tree ce70cdebe4dac4ba2543d1bb6d1e507aa2fd5da7
parent 82ca26fa474171326de9851a2f547c490f8e7276
author Jamal Hadi Salim <hadi@cyberus.ca> Thu, 07 Aug 2008 09:15:22 -0400
committer Jamal Hadi Salim <hadi@cyberus.ca> Thu, 07 Aug 2008 09:15:22 -0400

 net/wireless/wext.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/wireless/wext.c b/net/wireless/wext.c
index df5b388..d98ffb7 100644
--- a/net/wireless/wext.c
+++ b/net/wireless/wext.c
@@ -1277,6 +1277,7 @@ static int rtnetlink_fill_iwinfo(struct sk_buff *skb, struct net_device *dev,
 	r->ifi_flags = dev_get_flags(dev);
 	r->ifi_change = 0;	/* Wireless changes don't affect those flags */
 
+	NLA_PUT_STRING(skb, IFLA_IFNAME, dev->name);
 	/* Add the wireless events in the netlink packet */
 	NLA_PUT(skb, IFLA_WIRELESS, event_len, event);
 

--=-jF+ZTBye8ajLfqtqVjI+--

