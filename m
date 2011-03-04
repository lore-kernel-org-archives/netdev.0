From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: [PATCH 2/4] af_packet: struct socket declared/assigned but unused
Date: Fri,  4 Mar 2011 22:45:04 +0100
Message-ID: <1299275106-11513-2-git-send-email-hagen@jauu.net>
References: <1299275106-11513-1-git-send-email-hagen@jauu.net>
Cc: Hagen Paul Pfeifer <hagen@jauu.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:39156 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1760244Ab1CDVpJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2011 16:45:09 -0500
In-Reply-To: <1299275106-11513-1-git-send-email-hagen@jauu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
---
 net/packet/af_packet.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 5efef5b..b5362e9 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -966,7 +966,6 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
 
 static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 {
-	struct socket *sock;
 	struct sk_buff *skb;
 	struct net_device *dev;
 	__be16 proto;
@@ -978,8 +977,6 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 	int len_sum = 0;
 	int status = 0;
 
-	sock = po->sk.sk_socket;
-
 	mutex_lock(&po->pg_vec_lock);
 
 	err = -EBUSY;
-- 
1.7.4.1.57.g0466.dirty

