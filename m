From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH] ipv6: document ndisc_notify in networking/ip-sysctl.txt
Date: Tue, 1 Jan 2013 11:35:31 +0100
Message-ID: <20130101103531.GA31191@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:58344 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751774Ab3AAKfd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jan 2013 05:35:33 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I slipped in a new sysctl without proper documentation. I would like to
make up for this now.

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 Documentation/networking/ip-sysctl.txt | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 614320f..3f24319 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1344,6 +1344,12 @@ force_tllao - BOOLEAN
 	race condition where the sender deletes the cached link-layer address
 	prior to receiving a response to a previous solicitation."
 
+ndisc_notify - BOOLEAN
+	Define mode for notification of address and device changes.
+	0 - (default): do nothing
+	1 - Generate unsolicited neighbour advertisements when device is brought
+	    up or hardware address changes.
+
 icmp/*:
 ratelimit - INTEGER
 	Limit the maximal rates for sending ICMPv6 packets.
