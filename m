From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] tcp_vegas_cong_avoid doc
Date: Mon, 26 Apr 2004 10:12:10 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040426101210.461726d2@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Patch to update sysctl documentation to include tcp_vegas.
Feel free to rewrite for better explanation.

diff -Nru a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
--- a/Documentation/networking/ip-sysctl.txt	Mon Apr 26 10:09:25 2004
+++ b/Documentation/networking/ip-sysctl.txt	Mon Apr 26 10:09:25 2004
@@ -307,6 +307,15 @@
 	wired networks and throughput over wireless links.   
         Default: 0
 
+tcp_vegas_cong_avoid - BOOLEAN
+	Enable TCP Vegas congestion avoidance algorithm.
+	TCP Vegas is a sender-side only change to TCP that anticipates
+	the onset of congestion by estimating the bandwidth. TCP Vegas
+	adjusts the sending rate by modifying the congestion
+	window. TCP Vegas should provide less packet loss, but is not
+	be as aggressive as TCP Reno.
+	Default:0
+
 ip_local_port_range - 2 INTEGERS
 	Defines the local port range that is used by TCP and UDP to
 	choose the local port. The first number is the first, the 
