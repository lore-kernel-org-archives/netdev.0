From: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Subject: [PATCH v2 -mm 4/9] netconsole: Add some useful tips to documentation
Date: Tue, 10 Jul 2007 14:49:41 +0530
Message-ID: <20070710091941.23907.45658.sendpatchset@cselinux1.cse.iitk.ac.in>
References: <20070710091920.23907.96483.sendpatchset@cselinux1.cse.iitk.ac.in>
Cc: Matt Mackall <mpm@selenic.com>,
	Keiichi Kii <k-keiichi@bx.jp.nec.com>,
	Satyam Sharma <ssatyam@cse.iitk.ac.in>,
	Netdev <netdev@vger.kernel.org>,
	Joel Becker <joel.becker@oracle.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.iitk.ac.in ([203.197.196.4]:56095 "EHLO mail4.iitk.ac.in"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758994AbXGJI51 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2007 04:57:27 -0400
In-Reply-To: <20070710091920.23907.96483.sendpatchset@cselinux1.cse.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Satyam Sharma <ssatyam@cse.iitk.ac.in>

[4/9] netconsole: Add some useful tips to documentation

Add some useful general-purpose tips.

Signed-off-by: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Cc: Keiichi Kii <k-keiichi@bx.jp.nec.com>

---

 Documentation/networking/netconsole.txt |   13 +++++++++++++
 1 file changed, 13 insertions(+)

---

diff -ruNp a/Documentation/networking/netconsole.txt b/Documentation/networking/netconsole.txt
--- a/Documentation/networking/netconsole.txt	2007-04-26 08:38:32.000000000 +0530
+++ b/Documentation/networking/netconsole.txt	2007-07-10 07:31:12.000000000 +0530
@@ -44,6 +44,19 @@ WARNING: the default target ethernet set
 ethernet address to send packets, which can cause increased load on
 other systems on the same ethernet segment.
 
+TIP: some LAN switches may be configured to suppress ethernet broadcasts
+so it is advised to explicitly specify the remote agents' MAC addresses
+from the config parameters passed to netconsole.
+
+TIP: to find out the MAC address of, say, 10.0.0.2, you may try using:
+
+ ping -c 1 10.0.0.2 ; /sbin/arp -n | grep 10.0.0.2
+
+TIP: in case the remote logging agent is on a separate LAN subnet than
+the sender, it is suggested to try specifying the MAC address of the
+default gateway (you may use /sbin/route -n to find it out) as the
+remote MAC address instead.
+
 NOTE: the network device (eth1 in the above case) can run any kind
 of other network traffic, netconsole is not intrusive. Netconsole
 might cause slight delays in other traffic if the volume of kernel
