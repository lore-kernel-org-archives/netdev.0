From: raj@tardy.usa.hp.com (Rick Jones)
Subject: [PATCH net-next] doc: make the description of how tcp_ecn works more explicit and clear
Date: Wed, 28 Nov 2012 11:53:10 -0800 (PST)
Message-ID: <20121128195310.C438D2900459@tardy>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:27346 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754501Ab2K1TxO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 14:53:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones <rick.jones2@hp.com>

Make the description of how tcp_ecn works a bit more explicit and clear.


Signed-off-by: Rick Jones <rick.jones2@hp.com>

---

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 98ac0d7..2992160 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -199,15 +199,16 @@ tcp_early_retrans - INTEGER
 	Default: 2
 
 tcp_ecn - INTEGER
-	Enable Explicit Congestion Notification (ECN) in TCP. ECN is only
-	used when both ends of the TCP flow support it. It is useful to
-	avoid losses due to congestion (when the bottleneck router supports
-	ECN).
+	Control use of Explicit Congestion Notification (ECN) by TCP.
+	ECN is used only when both ends of the TCP connection indicate
+	support for it.  This feature is useful in avoiding losses due
+	to congestion by allowing supporting routers to signal
+	congestion before having to drop packets.
 	Possible values are:
-		0 disable ECN
-		1 ECN enabled
-		2 Only server-side ECN enabled. If the other end does
-		  not support ECN, behavior is like with ECN disabled.
+		0 Disable ECN.  Neither initiate nor accept ECN.
+		1 Always request ECN on outgoing connection attempts.
+		2 Enable ECN when requested by incomming connections
+		  but do not request ECN on outgoing connections.
 	Default: 2
 
 tcp_fack - BOOLEAN
