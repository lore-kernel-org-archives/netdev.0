From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] tcp_vegas_cong_avoid doc
Date: Mon, 26 Apr 2004 16:32:21 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040426163221.56a08130.davem@redhat.com>
References: <20040426101210.461726d2@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040426101210.461726d2@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 26 Apr 2004 10:12:10 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Patch to update sysctl documentation to include tcp_vegas.
> Feel free to rewrite for better explanation.

I applied this, only changing a minor grammatical error at the
end.  See attached...

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/04/26 16:31:03-07:00 shemminger@osdl.org 
#   [TCP]: Add vegas sysctl docs.
# 
# Documentation/networking/ip-sysctl.txt
#   2004/04/26 16:30:36-07:00 shemminger@osdl.org +9 -0
#   [TCP]: Add vegas sysctl docs.
# 
diff -Nru a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
--- a/Documentation/networking/ip-sysctl.txt	Mon Apr 26 16:31:29 2004
+++ b/Documentation/networking/ip-sysctl.txt	Mon Apr 26 16:31:29 2004
@@ -307,6 +307,15 @@
 	wired networks and throughput over wireless links.   
         Default: 0
 
+tcp_vegas_cong_avoid - BOOLEAN
+	Enable TCP Vegas congestion avoidance algorithm.
+	TCP Vegas is a sender-side only change to TCP that anticipates
+	the onset of congestion by estimating the bandwidth. TCP Vegas
+	adjusts the sending rate by modifying the congestion
+	window. TCP Vegas should provide less packet loss, but it is
+	not as aggressive as TCP Reno.
+	Default:0
+
 ip_local_port_range - 2 INTEGERS
 	Defines the local port range that is used by TCP and UDP to
 	choose the local port. The first number is the first, the 
