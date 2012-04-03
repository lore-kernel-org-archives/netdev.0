From: fernando@intellilink.co.jp
Subject: [PATCH 1/2] TCP: update ip_local_port_range documentation
Date: Tue,  3 Apr 2012 09:48:40 +0900
Message-ID: <20120403094840.ftxlwztl40gwcg4s@webmail.int.intellilink.co.jp>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="=_2jpxizgkdq0w"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ils-mail01.intellilink.co.jp ([61.115.36.70]:50417 "EHLO
	ils-mail01.intellilink.co.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751691Ab2DCBLG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Apr 2012 21:11:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This message is in MIME format.

--=_2jpxizgkdq0w
Content-Type: text/plain;
	charset=ISO-2022-JP;
	format="flowed"
Content-Disposition: inline
Content-Transfer-Encoding: 7bit



--=_2jpxizgkdq0w
Content-Type: text/plain;
	charset=ISO-2022-JP;
	name="sysctl-ip_local_port_range-documentation.patch"
Content-Disposition: attachment;
	filename="sysctl-ip_local_port_range-documentation.patch"
Content-Transfer-Encoding: 7bit

Subject: [PATCH] TCP: update ip_local_port_range documentation

From: Fernando Luis Vazquez Cao <fernando@oss.ntt.co.jp>

The explanation of ip_local_port_range in Documentation/networking/ip-sysctl.txt
contains several factual errors:

- The default value of ip_local_port_range does not depend on the amount of
  memory available in the system.
- tcp_tw_recycle is not enabled by default.
- 1024-4999 is not the default value.

Fix them.

Signed-off-by: Fernando Luis Vazquez Cao <fernando@oss.ntt.co.jp>
---

diff -urNp linux-3.4-rc1-orig/Documentation/networking/ip-sysctl.txt linux-3.4-rc1/Documentation/networking/ip-sysctl.txt
--- linux-3.4-rc1-orig/Documentation/networking/ip-sysctl.txt	2012-03-19 08:15:34.000000000 +0900
+++ linux-3.4-rc1/Documentation/networking/ip-sysctl.txt	2012-04-03 07:42:56.793550547 +0900
@@ -604,15 +604,12 @@ IP Variables:
 ip_local_port_range - 2 INTEGERS
 	Defines the local port range that is used by TCP and UDP to
 	choose the local port. The first number is the first, the
-	second the last local port number. Default value depends on
-	amount of memory available on the system:
-	> 128Mb 32768-61000
-	< 128Mb 1024-4999 or even less.
-	This number defines number of active connections, which this
-	system can issue simultaneously to systems not supporting
-	TCP extensions (timestamps). With tcp_tw_recycle enabled
-	(i.e. by default) range 1024-4999 is enough to issue up to
-	2000 connections per second to systems supporting timestamps.
+	second the last local port number. The default values are 
+	32768 and 61000 respectively.
+
+	These two numbers determine the number of active connections
+	which this system can issue simultaneously to systems not
+	supporting TCP extensions (timestamps).
 
 ip_local_reserved_ports - list of comma separated ranges
 	Specify the ports which are reserved for known third-party

--=_2jpxizgkdq0w--
