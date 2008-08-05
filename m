From: Robert Olsson <robert@robur.slu.se>
Subject: [PATCH] pktgen mac count
Date: Tue, 5 Aug 2008 13:27:52 +0200
Message-ID: <18584.14648.22535.119913@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eneas.hunguana@gmail.com,
	robert@robur.slu.se
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from robur.slu.se ([130.238.98.12]:42160 "EHLO robur.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753953AbYHEL1x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Aug 2008 07:27:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



One more...

dst_mac_count and src_mac_count patch from Eneas Hunguana
We have sent one mac address to much.


Signed-off-by: Robert Olsson <robert.olsson@its.uu.se>

Cheers.
					--ro


--- a/net/core/pktgen.c	2008-06-09 20:27:19.000000000 +0200
+++ b/net/core/pktgen.c	2008-07-06 03:06:00.000000000 +0200
@@ -2143,7 +2143,7 @@
 			mc = random32() % pkt_dev->src_mac_count;
 		else {
 			mc = pkt_dev->cur_src_mac_offset++;
-			if (pkt_dev->cur_src_mac_offset >
+			if (pkt_dev->cur_src_mac_offset >=
 			    pkt_dev->src_mac_count)
 				pkt_dev->cur_src_mac_offset = 0;
 		}
@@ -2170,7 +2170,7 @@
 
 		else {
 			mc = pkt_dev->cur_dst_mac_offset++;
-			if (pkt_dev->cur_dst_mac_offset >
+			if (pkt_dev->cur_dst_mac_offset >=
 			    pkt_dev->dst_mac_count) {
 				pkt_dev->cur_dst_mac_offset = 0;
 			}

