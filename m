From: osprey67 <osprey67@yahoo.com>
Subject: [PATCH 02/05] ipv6: RFC4214 Support (3)
Date: Fri, 09 Nov 2007 16:35:09 -0800
Message-ID: <4734FCBD.5080708@yahoo.com>
References: <473371B3.5030908@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: osprey67 <osprey67@yahoo.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp101.plus.mail.sp1.yahoo.com ([69.147.95.64]:37956 "HELO
	smtp101.plus.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750850AbXKJAmT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2007 19:42:19 -0500
In-Reply-To: <473371B3.5030908@yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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


