From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?= <remi@remlab.net>
Subject: [PATCH] Phonet: fix netlink address dump error handling
Date: Wed,  9 Sep 2009 12:59:51 +0300
Message-ID: <1252490391-27848-1-git-send-email-remi@remlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:47716 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751634AbZIIKFt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Sep 2009 06:05:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 net/phonet/pn_netlink.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/phonet/pn_netlink.c b/net/phonet/pn_netlink.c
index f8b4cee..d21fd35 100644
--- a/net/phonet/pn_netlink.c
+++ b/net/phonet/pn_netlink.c
@@ -147,7 +147,7 @@ static int getaddr_dumpit(struct sk_buff *skb, stru=
ct netlink_callback *cb)
=20
 			if (fill_addr(skb, pnd->netdev, addr << 2,
 					 NETLINK_CB(cb->skb).pid,
-					cb->nlh->nlmsg_seq, RTM_NEWADDR))
+					cb->nlh->nlmsg_seq, RTM_NEWADDR) < 0)
 				goto out;
 		}
 	}
--=20
1.6.0.4

