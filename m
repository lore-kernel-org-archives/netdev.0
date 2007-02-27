From: John Heffner <jheffner@psc.edu>
Subject: [PATCH 2/3] TCP sysctl documentation: MTU probing
Date: Mon, 26 Feb 2007 20:09:35 -0500
Message-ID: <45E384CF.2020800@psc.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090103060204080207070101"
To: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:54927 "EHLO mailer1.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161044AbXB0BJl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Feb 2007 20:09:41 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090103060204080207070101
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


--------------090103060204080207070101
Content-Type: text/plain; x-mac-type="0"; x-mac-creator="0";
 name="doc3.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="doc3.patch"

Documentation for sysctls tcp_mtu_probing and tcp_base_mss.

Signed-off-by: John Heffner <jheffner@psc.edu>

---
commit 6da0563572e0a6d0abda9d950f30902844c37862
tree 6f21ae02c11a1340412a926e8e2f568f5ed3b5a8
parent 17cb799000caef3b2fed28cc5d0601bb2311efa8
author John Heffner <jheffner@psc.edu> Mon, 26 Feb 2007 20:02:35 -0500
committer John Heffner <jheffner@psc.edu> Mon, 26 Feb 2007 20:02:35 -0500

 Documentation/networking/ip-sysctl.txt |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 891f389..d3aae1f 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -147,6 +147,11 @@ tcp_available_congestion_control - STRING
 	More congestion control algorithms may be available as modules,
 	but not loaded.
 
+tcp_base_mss - INTEGER
+	The initial value of search_low to be used by Packetization Layer
+	Path MTU Discovery (MTU probing).  If MTU probing is enabled,
+	this is the inital MSS used by the connection.
+
 tcp_congestion_control - STRING
 	Set the congestion control algorithm to be used for new
 	connections. The algorithm "reno" is always available, but
@@ -249,6 +254,13 @@ tcp_moderate_rcvbuf - BOOLEAN
 	match the size required by the path for full throughput.  Enabled by
 	default.
 
+tcp_mtu_probing - INTEGER
+	Controls TCP Packetization-Layer Path MTU Discovery.  Takes three
+	values:
+	  0 - Disabled
+	  1 - Disabled by default, enabled when an ICMP black hole detected
+	  2 - Always enabled, use initial MSS of tcp_base_mss.
+
 tcp_no_metrics_save - BOOLEAN
 	By default, TCP saves various connection metrics in the route cache
 	when the connection closes, so that connections established in the

--------------090103060204080207070101--
