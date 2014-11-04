From: Loganaden Velvindron <logan@elandsys.com>
Subject: Re: [PATCH] Add missing descriptions for fwmark_reflect for ipv4 and
 ipv6.
Date: Tue, 4 Nov 2014 03:02:49 -0800
Message-ID: <20141104110249.GA25828@mx.elandsys.com>
References: <20141029172915.GA15714@mx.elandsys.com>
 <20141030.161137.1421672304905070027.davem@davemloft.net>
 <20141104105650.GA5233@mx.elandsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1.qubic.net ([208.69.177.116]:55290 "EHLO mx.elandsys.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752676AbaKDLCv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Nov 2014 06:02:51 -0500
Content-Disposition: inline
In-Reply-To: <20141104105650.GA5233@mx.elandsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It was initially sent by Lorenzo Colitti, but was subsequently
lost in the final diff he submitted.

Signed-off-by: Loganaden Velvindron <logan@elandsys.com>
---
 Documentation/networking/ip-sysctl.txt | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 0307e28..a476b08 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -56,6 +56,13 @@ ip_forward_use_pmtu - BOOLEAN
 	0 - disabled
 	1 - enabled
 
+fwmark_reflect - BOOLEAN
+	Controls the fwmark of kernel-generated IPv4 reply packets that are not
+	associated with a socket for example, TCP RSTs or ICMP echo replies).
+	If unset, these packets have a fwmark of zero. If set, they have the
+	fwmark of the packet they are replying to.
+	Default: 0
+
 route/max_size - INTEGER
 	Maximum number of routes allowed in the kernel.  Increase
 	this when using large numbers of interfaces and/or routes.
@@ -1201,6 +1208,13 @@ conf/all/forwarding - BOOLEAN
 proxy_ndp - BOOLEAN
 	Do proxy ndp.
 
+fwmark_reflect - BOOLEAN
+	Controls the fwmark of kernel-generated IPv6 reply packets that are not
+	associated with a socket for example, TCP RSTs or ICMPv6 echo replies).
+	If unset, these packets have a fwmark of zero. If set, they have the
+	fwmark of the packet they are replying to.
+	Default: 0
+
 conf/interface/*:
 	Change special settings per interface.
 
-- 
1.9.1
