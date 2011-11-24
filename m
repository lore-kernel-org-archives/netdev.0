From: Alex Juncu <ajuncu@ixiacom.com>
Subject: [PATCH 1/1] Adding examples in ip man page on basic use of the ip
 command.
Date: Thu, 24 Nov 2011 14:00:54 +0200
Message-ID: <4ECE31F6.4070002@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>, <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 207.47.100.214.static.nextweb.net ([207.47.100.214]:1592 "EHLO
	ixqw-mail-out.ixiacom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753789Ab1KXMGW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2011 07:06:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---
  man/man8/ip.8 |   43 +++++++++++++++++++++++++++++++++++++++++++
  1 files changed, 43 insertions(+), 0 deletions(-)

diff --git a/man/man8/ip.8 b/man/man8/ip.8
index a20eca7..99c8953 100644
--- a/man/man8/ip.8
+++ b/man/man8/ip.8
@@ -2855,6 +2855,49 @@ can be
  .SS ip xfrm monitor - state monitoring for xfrm objects
  The xfrm objects to monitor can be optionally specified.

+.SH EXAMPLES
+.LP
+To turn on an interface:
+.RS
+.nf
+.B ip link set up dev eth0
+.fi
+.RE
+.LP
+To add an IPv4 address to an interface:
+.RS
+.nf
+.B ip address add 141.85.37.42/24 dev eth0
+.fi
+.RE
+.LP
+To add a default route in the IPv4 routing table using a next hop IP 
address:
+.RS
+.nf
+.B ip route add  default via 141.85.37.1
+.fi
+.RE
+.LP
+Equivalent ways of listing address information for all the interfaces:
+.RS
+.nf
+.B ip addr show
+.fi
+.RE
+.LP
+.RS
+.nf
+.B ip a s
+.fi
+.RE
+.LP
+.RS
+.nf
+.B ip a
+.fi
+.RE
+.LP
+
  .SH HISTORY
  .B ip
  was written by Alexey N. Kuznetsov and added in Linux 2.2.
-- 
1.7.4.1
