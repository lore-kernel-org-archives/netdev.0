From: "Templin, Fred L" <Fred.L.Templin@boeing.com>
Subject: [Resend] [PATCH 02/05] ipv6: RFC4214 Support (4)
Date: Mon, 12 Nov 2007 13:01:18 -0800
Message-ID: <39C363776A4E8C4A94691D2BD9D1C9A1029EDC15@XCH-NW-7V2.nw.nos.boeing.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Cc: =?iso-2022-jp?B?WU9TSElGVUpJIEhpZGVha2kgLyAbJEI1SEYjMVFMQBsoQg==?=
	<yoshfuji@linux-ipv6.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from slb-smtpout-01.boeing.com ([130.76.64.48]:37168 "EHLO
	slb-smtpout-01.boeing.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760082AbXKLVBh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Nov 2007 16:01:37 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 

-----Original Message-----
From: osprey67 [mailto:osprey67@yahoo.com] 
Sent: Monday, November 12, 2007 7:55 AM
To: netdev@vger.kernel.org
Subject: [PATCH 02/05] ipv6: RFC4214 Support (4)

From: Fred L. Templin <fred.l.templin@boeing.com>

This is experimental support for the Intra-Site Automatic
Tunnel Addressing Protocol (ISATAP) per RFC4214. It uses
the SIT module, and is configured using the unmodified
"ip" utility with device names beginning with: "isatap".

The following diffs are specific to the Linux 2.6.24-rc2
kernel distribution.

Signed-off-by: Fred L. Templin <fred.l.templin@boeing.com>

---

--- linux-2.6.24-rc2/net/ipv6/Kconfig.orig      2007-11-08 12:07:17.000000000 -0800
+++ linux-2.6.24-rc2/net/ipv6/Kconfig   2007-11-08 08:27:48.000000000 -0800
@@ -57,6 +57,17 @@ config IPV6_ROUTE_INFO

           If unsure, say N.

+config IPV6_ISATAP
+       bool "IPv6: ISATAP (RFC 4214) support (EXPERIMENTAL)"
+       depends on IPV6 && EXPERIMENTAL
+       ---help---
+         This is experimental support for the Intra-Site Automatic
+         Tunnel Addressing Protocol (ISATAP) per RFC4214. It uses
+         the SIT module, and is configured using the "ip" utility
+         with device names beginning with: "isatap".
+
+         If unsure, say N.
+
  config IPV6_OPTIMISTIC_DAD
         bool "IPv6: Enable RFC 4429 Optimistic DAD (EXPERIMENTAL)"
         depends on IPV6 && EXPERIMENTAL

-
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
