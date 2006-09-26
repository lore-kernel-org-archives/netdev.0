From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: [PATCH] Documentation update pktgen
Date: Tue, 26 Sep 2006 16:23:46 +0200
Message-ID: <17689.14322.908796.178905@robur.slu.se>
References: <17689.13986.848022.719899@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Robert.Olsson@data.slu.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:903 "EHLO mx1.slu.se")
	by vger.kernel.org with ESMTP id S1750827AbWIZOXv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2006 10:23:51 -0400
To: "Francesco Fondelli" <francesco.fondelli@gmail.com>
In-Reply-To: <17689.13986.848022.719899@robur.slu.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



And the docs.

Cheers.
					--ro


Signed-off-by: Francesco Fondelli <francesco.fondelli@gmail.com>
Signed-off-by: Robert Olsson <robert.olsson@its.uu.se>

diff --git a/Documentation/networking/pktgen.txt b/Documentation/networking/pktgen.txt
index 278771c..6062e35 100644
--- a/Documentation/networking/pktgen.txt
+++ b/Documentation/networking/pktgen.txt
@@ -100,6 +100,7 @@ Examples:
                          are: IPSRC_RND #IP Source is random (between min/max),
                               IPDST_RND, UDPSRC_RND,
                               UDPDST_RND, MACSRC_RND, MACDST_RND 
+                              MPLS_RND, VID_RND, SVID_RND 
 
  pgset "udp_src_min 9"   set UDP source port min, If < udp_src_max, then
                          cycle through the port range.
@@ -125,6 +126,21 @@ Examples:
 
  pgset "mpls 0"		  turn off mpls (or any invalid argument works too!)
 
+ pgset "vlan_id 77"       set VLAN ID 0-4095
+ pgset "vlan_p 3"         set priority bit 0-7 (default 0)
+ pgset "vlan_cfi 0"       set canonical format identifier 0-1 (default 0)
+
+ pgset "svlan_id 22"      set SVLAN ID 0-4095
+ pgset "svlan_p 3"        set priority bit 0-7 (default 0)
+ pgset "svlan_cfi 0"      set canonical format identifier 0-1 (default 0)
+
+ pgset "vlan_id 9999"     > 4095 remove vlan and svlan tags
+ pgset "svlan 9999"       > 4095 remove svlan tag
+
+
+ pgset "tos XX"           set former IPv4 TOS field (e.g. "tos 28" for AF11 no ECN, default 00)
+ pgset "traffic_class XX" set former IPv6 TRAFFIC CLASS (e.g. "traffic_class B8" for EF no ECN, default 00)
+
  pgset stop    	          aborts injection. Also, ^C aborts generator.
 
 
