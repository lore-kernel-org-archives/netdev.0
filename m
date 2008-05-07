From: "J.H.M. Dassen (Ray)" <jdassen@debian.org>
Subject: [PATCH] net/ipv4: Correct RFC 1122 section reference in comment
Date: Wed, 7 May 2008 09:24:23 +0200
Message-ID: <20080507072423.GA13556@xinara.org>
References: <bug-10611-10286@http.bugzilla.kernel.org/> <20080506233351.1fe19fe6.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, trivial@kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zensunni.xinara.org ([62.212.135.161]:60536 "EHLO
	zensunni.xinara.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753897AbYEGHvJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2008 03:51:09 -0400
Content-Disposition: inline
In-Reply-To: <20080506233351.1fe19fe6.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: J.H.M. Dassen (Ray) <jdassen@debian.org>

RFC 1122 does not have a section 3.1.2.2. The requirement to silently
discard datagrams with a bad checksum is in section 3.2.1.2 instead.

Signed-off-by: J.H.M. Dassen (Ray) <jdassen@debian.org>

---

Previously submitted as http://bugzilla.kernel.org/show_bug.cgi?id=10611

diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 212734c..5bdb8f4 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -394,7 +394,7 @@ int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt,
 	iph = skb->nh.iph;
 
 	/*
-	 *	RFC1122: 3.1.2.2 MUST silently discard any IP frame that fails the checksum.
+	 *	RFC1122: 3.2.1.2 MUST silently discard any IP frame that fails the checksum.
 	 *
 	 *	Is the datagram acceptable?
 	 *

-- 
LEADERSHIP  A form of self-preservation exhibited by people with auto-
destructive imaginations in order to ensure that when it comes to the crunch
it'll be someone else's bones which go crack and not their own.
    - The Hipcrime Vocab by Chad C. Mulligan
