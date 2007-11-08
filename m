From: osprey67 <osprey67@yahoo.com>
Subject: [PATCH 01/05] ipv6: RFC4214 Support (2)
Date: Thu, 08 Nov 2007 12:29:39 -0800
Message-ID: <473371B3.5030908@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp121.plus.mail.mud.yahoo.com ([209.191.106.152]:48837 "HELO
	smtp121.plus.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753895AbXKHUgb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Nov 2007 15:36:31 -0500
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

--- linux-2.6.24-rc2/include/linux/if.h.orig    2007-11-08 12:05:47.000000000 -0800
+++ linux-2.6.24-rc2/include/linux/if.h 2007-11-08 08:26:44.000000000 -0800
@@ -61,6 +61,7 @@
  #define IFF_MASTER_ALB 0x10            /* bonding master, balance-alb. */
  #define IFF_BONDING    0x20            /* bonding master or slave      */
  #define IFF_SLAVE_NEEDARP 0x40         /* need ARPs for validation     */
+#define IFF_ISATAP     0x80            /* ISATAP interface (RFC4214)   */

  #define IF_GET_IFACE   0x0001          /* for querying only */
  #define IF_GET_PROTO   0x0002
