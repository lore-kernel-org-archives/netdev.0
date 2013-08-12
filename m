From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next] net: documentation update for IGMP/MLD unsolicited report interval knobs
Date: Mon, 12 Aug 2013 05:33:58 +0200
Message-ID: <20130812033358.GA15405@order.stressinduktion.org>
References: <20130812014859.GA13886@order.stressinduktion.org> <ku9gvg$27t$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, william.manley@youview.com, bcrl@kvack.org
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:45344 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755619Ab3HLDeA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Aug 2013 23:34:00 -0400
Content-Disposition: inline
In-Reply-To: <ku9gvg$27t$1@ger.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joined documentation update for IPv4 and IPv6 MLD/IGMP
unsolicited_report_interval procfs knobs.

Cc: Cong Wang <xiyou.wangcong@gmail.com>
Cc: William Manley <william.manley@youview.com>
Cc: Benjamin LaHaise <bcrl@kvack.org>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 Documentation/networking/ip-sysctl.txt | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 36be26b..debfe85 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1039,7 +1039,15 @@ disable_policy - BOOLEAN
 disable_xfrm - BOOLEAN
 	Disable IPSEC encryption on this interface, whatever the policy
 
+igmpv2_unsolicited_report_interval - INTEGER
+	The interval in milliseconds in which the next unsolicited
+	IGMPv1 or IGMPv2 report retransmit will take place.
+	Default: 10000 (10 seconds)
 
+igmpv3_unsolicited_report_interval - INTEGER
+	The interval in milliseconds in which the next unsolicited
+	IGMPv3 report retransmit will take place.
+	Default: 1000 (1 seconds)
 
 tag - INTEGER
 	Allows you to write a number, which can be used as required.
@@ -1331,6 +1339,16 @@ ndisc_notify - BOOLEAN
 	1 - Generate unsolicited neighbour advertisements when device is brought
 	    up or hardware address changes.
 
+mldv1_unsolicited_report_interval - INTEGER
+	The interval in milliseconds in which the next unsolicited
+	MLDv1 report retransmit will take place.
+	Default: 10000 (10 seconds)
+
+mldv2_unsolicited_report_interval - INTEGER
+	The interval in milliseconds in which the next unsolicited
+	MLDv2 report retransmit will take place.
+	Default: 1000 (1 second)
+
 icmp/*:
 ratelimit - INTEGER
 	Limit the maximal rates for sending ICMPv6 packets.
-- 
1.8.3.1
