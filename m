From: Alberto Bertogli <albertogli@telpin.com.ar>
Subject: [PATCH] IPVS' Kconfig LBLC and LBLCR configuration typo
Date: Mon, 14 Jul 2003 11:03:50 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030714140350.GB1389@telpin.com.ar>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-net@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi there!

The following patch fixes what looks like a typo in ipvs' Kconfig
(net/ipv4/ipvs/Kconfig).

Both the IP_VS_LBLC and IP_VS_LBLCR schedulings have the same tristate
line (well, not the same, IP_VS_LBLCR's has a 'g' missing at the end):

tristate "locality-based least-connection with replication scheduling"

But it looks like LBLC should be "locality-based least-connection
scheduling" and LBLCR "locality-based least-connection with replication
scheduling".


Thanks,
		Alberto


--- Kconfig.orig	2003-07-14 10:32:06.000000000 -0300
+++ Kconfig	2003-07-14 10:32:57.000000000 -0300
@@ -147,7 +147,7 @@
 	  unsure, say N.
 
 config	IP_VS_LBLC
-	tristate "locality-based least-connection with replication scheduling"
+	tristate "locality-based least-connection scheduling"
         depends on IP_VS
 	---help---
 	  The locality-based least-connection scheduling algorithm is for
@@ -163,7 +163,7 @@
 	  unsure, say N.
 
 config  IP_VS_LBLCR
-	tristate "locality-based least-connection with replication schedulin"
+	tristate "locality-based least-connection with replication scheduling"
         depends on IP_VS
 	---help---
 	  The locality-based least-connection with replication scheduling
