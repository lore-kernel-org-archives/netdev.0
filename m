From: Dave Jones <davej@redhat.com>
Subject: Remove out of date message in appletalk printk
Date: Wed, 6 Jun 2012 14:45:59 -0400
Message-ID: <20120606184559.GA27763@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: acme@ghostprotocols.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5691 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751634Ab2FFSqE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jun 2012 14:46:04 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I accidentally triggered this printk, which amused me for a few moments.
Given we're post 2.2, we could just -EACCES, but does anyone even care about Appletalk now ?
I figure it's better to leave sleeping dogs lie, and just update the message.

Signed-off-by: Dave Jones <davej@redhat.com>

diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index 0301b32..12e9100 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -1208,9 +1208,7 @@ static int atalk_connect(struct socket *sock, struct sockaddr *uaddr,
 	if (addr->sat_addr.s_node == ATADDR_BCAST &&
 	    !sock_flag(sk, SOCK_BROADCAST)) {
 #if 1
-		printk(KERN_WARNING "%s is broken and did not set "
-				    "SO_BROADCAST. It will break when 2.2 is "
-				    "released.\n",
+		printk(KERN_WARNING "%s is broken and did not set SO_BROADCAST.\n",
 			current->comm);
 #else
 		return -EACCES;
