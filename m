From: Andrew Morton <akpm@linux-foundation.org>
Subject: net-core-rtnetlinkc-copy-paste-error-in-rtnl_bridge_notify.patch
Date: Thu, 3 Apr 2014 12:01:22 -0700
Message-ID: <20140403120122.fe50ce80260faf3fc3a4ae30@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>, Jiri Pirko <jiri@resnulli.us>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:59153 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753256AbaDCTBY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2014 15:01:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Guys, I've been sitting on this since January and simply cannot
remember what happened with it.  Is this still a thing or did it get
nacked, or...?

Thanks.


From: Yogesh Gaur <yogeshgaur.83@gmail.com>
Subject: net/core/rtnetlink.c: copy paste error in rtnl_bridge_notify()

Seems to be copy paste error in calling ndo_bridge_getlink() func.

Signed-off-by: Yogesh Gaur <yogeshgaur.83@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Vlad Yasevich <vyasevich@gmail.com>
Cc: Jiri Pirko <jiri@resnulli.us>
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/core/rtnetlink.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN net/core/rtnetlink.c~net-core-rtnetlinkc-copy-paste-error-in-rtnl_bridge_notify net/core/rtnetlink.c
--- a/net/core/rtnetlink.c~net-core-rtnetlinkc-copy-paste-error-in-rtnl_bridge_notify
+++ a/net/core/rtnetlink.c
@@ -2576,7 +2576,7 @@ static int rtnl_bridge_notify(struct net
 
 	if ((!flags || (flags & BRIDGE_FLAGS_MASTER)) &&
 	    br_dev && br_dev->netdev_ops->ndo_bridge_getlink) {
-		err = br_dev->netdev_ops->ndo_bridge_getlink(skb, 0, 0, dev, 0);
+		err = br_dev->netdev_ops->ndo_bridge_getlink(skb, 0, 0, br_dev, 0);
 		if (err < 0)
 			goto errout;
 	}
_
