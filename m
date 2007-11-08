From: osprey67 <osprey67@yahoo.com>
Subject: [PATCH 05/05] ipv6: RFC4214 Support (2)
Date: Thu, 08 Nov 2007 12:41:53 -0800
Message-ID: <47337491.20207@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp114.plus.mail.mud.yahoo.com ([209.191.106.145]:31833 "HELO
	smtp114.plus.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1760794AbXKHUlz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Nov 2007 15:41:55 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Fred L. Templin <osprey67@yahoo.com>

This is experimental support for the Intra-Site Automatic
Tunnel Addressing Protocol (ISATAP) per RFC4214. It uses
the SIT module, and is configured using the unmodified
"ip" utility with device names beginning with: "isatap".

The following diffs are specific to the Linux 2.6.24-rc2
kernel distribution.

Signed-off-by: Fred L. Templin <osprey67@yahoo.com>

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
