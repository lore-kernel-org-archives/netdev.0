From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] mrp: make mrp_rcv static
Date: Mon, 11 Feb 2013 08:25:24 -0800
Message-ID: <20130211082524.5fb3a976@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	David Ward <david.ward@ll.mit.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:39671 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757580Ab3BKQZj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2013 11:25:39 -0500
Received: by mail-pa0-f50.google.com with SMTP id fa11so3170560pad.23
        for <netdev@vger.kernel.org>; Mon, 11 Feb 2013 08:25:38 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sparse spotted local function that could be static.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/net/802/mrp.c	2013-02-11 08:13:10.324575963 -0800
+++ b/net/802/mrp.c	2013-02-11 08:23:13.076756457 -0800
@@ -744,8 +744,8 @@ static int mrp_pdu_parse_msg(struct mrp_
 	return 0;
 }
 
-int mrp_rcv(struct sk_buff *skb, struct net_device *dev,
-	    struct packet_type *pt, struct net_device *orig_dev)
+static int mrp_rcv(struct sk_buff *skb, struct net_device *dev,
+		   struct packet_type *pt, struct net_device *orig_dev)
 {
 	struct mrp_application *appl = container_of(pt, struct mrp_application,
 						    pkttype);
