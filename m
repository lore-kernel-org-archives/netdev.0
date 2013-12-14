From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net] ipv4: improve documentation of ip_no_pmtu_disc
Date: Sat, 14 Dec 2013 04:42:13 +0100
Message-ID: <20131214034213.GD7332@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:54742 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753158Ab3LNDmO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 22:42:14 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 Documentation/networking/ip-sysctl.txt | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 12ba2cd..f76d177 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -16,8 +16,12 @@ ip_default_ttl - INTEGER
 	Default: 64 (as recommended by RFC1700)
 
 ip_no_pmtu_disc - BOOLEAN
-	Disable Path MTU Discovery.
-	default FALSE
+	Disable Path MTU Discovery. If enabled and a
+	fragmentation-required ICMP is received, the PMTU to this
+	destination will be set to min_pmtu (see below). You will need
+	to raise min_pmtu to the smallest interface MTU on your system
+	manually if you want to avoid locally generated fragments.
+	Default: FALSE
 
 min_pmtu - INTEGER
 	default 552 - minimum discovered Path MTU
-- 
1.8.3.1
