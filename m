From: "Templin, Fred L" <Fred.L.Templin@boeing.com>
Subject: [PATCH 05/05] ipv6: RFC4214 Support
Date: Tue, 6 Nov 2007 17:16:14 -0800
Message-ID: <39C363776A4E8C4A94691D2BD9D1C9A1029EDBE6@XCH-NW-7V2.nw.nos.boeing.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stl-smtpout-01.boeing.com ([130.76.96.56]:47259 "EHLO
	stl-smtpout-01.boeing.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755247AbXKGBfj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2007 20:35:39 -0500
Received: from blv-av-01.boeing.com (blv-av-01.boeing.com [192.42.227.216])
	by stl-smtpout-01.ns.cs.boeing.com (8.14.0/8.14.0/8.14.0/SMTPOUT) with ESMTP id lA71GOBn011017
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 6 Nov 2007 19:16:24 -0600 (CST)
Received: from blv-av-01.boeing.com (localhost [127.0.0.1])
	by blv-av-01.boeing.com (8.14.0/8.14.0/DOWNSTREAM_RELAY) with ESMTP id lA71GNGl026619
	for <netdev@vger.kernel.org>; Tue, 6 Nov 2007 17:16:23 -0800 (PST)
Received: from XCH-NWBH-11.nw.nos.boeing.com (xch-nwbh-11.nw.nos.boeing.com [130.247.55.84])
	by blv-av-01.boeing.com (8.14.0/8.14.0/UPSTREAM_RELAY) with ESMTP id lA71GLX3026498
	for <netdev@vger.kernel.org>; Tue, 6 Nov 2007 17:16:23 -0800 (PST)
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Fred L. Templin <fred.l.templin@boeing.com>

This is experimental support for the Intra-Site Automatic
Tunnel Addressing Protocol (ISATAP) per RFC4214. It uses
the SIT module, and is configured using the unmodified
"ip" utility with device names beginning with: "isatap".

The following diffs are specific to the Linux 2.6.23
kernel distribution.

Signed-off-by: Fred L. Templin <fred.l.templin@boeing.com>

---

--- linux-2.6.23/net/ipv6/Kconfig.orig	2007-10-31 11:15:13.000000000
-0700
+++ linux-2.6.23/net/ipv6/Kconfig	2007-10-31 11:18:32.000000000
-0700
@@ -57,6 +57,17 @@ config IPV6_ROUTE_INFO
 
 	  If unsure, say N.
 
+config IPV6_ISATAP
+	bool "IPv6: ISATAP (RFC 4214) support (EXPERIMENTAL)"
+	depends on IPV6 && EXPERIMENTAL
+	---help---
+	  This is experimental support for the Intra-Site Automatic
+	  Tunnel Addressing Protocol (ISATAP) per RFC4214. It uses
+	  the SIT module, and is configured using the "ip" utility
+	  with device names beginning with: "isatap".
+
+	  If unsure, say N.
+
 config IPV6_OPTIMISTIC_DAD
 	bool "IPv6: Enable RFC 4429 Optimistic DAD (EXPERIMENTAL)"
 	depends on IPV6 && EXPERIMENTAL
