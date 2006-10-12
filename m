From: Patrick McHardy <kaber@trash.net>
Subject: [RTNETLINK]: Fix use of wrong skb in do_getlink()
Date: Thu, 12 Oct 2006 08:40:57 +0200
Message-ID: <452DE379.6010807@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080100040905080903030505"
Cc: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55263 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S932505AbWJLGjb
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Oct 2006 02:39:31 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080100040905080903030505
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit


--------------080100040905080903030505
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[RTNETLINK]: Fix use of wrong skb in do_getlink()

skb is the netlink query, nskb is the reply message.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 7d6fc0796ea33cd86cf20ccd51c351538903dcd9
tree 15bd1793a030f471f4a70762b079cf187bca8207
parent 587b522ced8a8ca3bddc99b05ec5118f11cfe164
author Patrick McHardy <kaber@trash.net> Thu, 12 Oct 2006 08:38:03 +0200
committer Patrick McHardy <kaber@trash.net> Thu, 12 Oct 2006 08:38:03 +0200

 net/core/rtnetlink.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 221e403..02f3c79 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -602,7 +602,7 @@ #endif	/* CONFIG_NET_WIRELESS_RTNETLINK 
 		goto errout;
 	}
 
-	err = rtnl_unicast(skb, NETLINK_CB(skb).pid);
+	err = rtnl_unicast(nskb, NETLINK_CB(skb).pid);
 errout:
 	kfree(iw_buf);
 	dev_put(dev);

--------------080100040905080903030505--
