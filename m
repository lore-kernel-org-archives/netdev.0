From: Loganaden Velvindron <logan@elandsys.com>
Subject: [PATCH] Add missing descriptions for fwmark_reflect for ipv4 and
 ipv6.
Date: Wed, 29 Oct 2014 10:56:41 -0700
Message-ID: <20141029175641.GA27727@mx.elandsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1.qubic.net ([208.69.177.116]:60707 "EHLO mx.elandsys.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755952AbaJ2R4n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Oct 2014 13:56:43 -0400
Received: from mx.elandsys.com (IDENT:logan@localhost [127.0.0.1])
	by mx.elandsys.com (8.14.5/8.14.5) with ESMTP id s9THugXb026144
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 29 Oct 2014 10:56:42 -0700 (PDT)
Received: (from logan@localhost)
	by mx.elandsys.com (8.14.5/8.14.5/Submit) id s9THufFc013035
	for netdev@vger.kernel.org; Wed, 29 Oct 2014 10:56:41 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

It was initially sent by Lorenzo Colitti, but was subsequently
lost in the final diff he submitted.

(It's my first diff, please let me know if I screwed up in the submission
process)

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
