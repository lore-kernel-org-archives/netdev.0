From: fernando@intellilink.co.jp
Subject: [PATCH] TCP: update ip_local_port_range documentation
Date: Tue,  3 Apr 2012 20:12:21 +0900
Message-ID: <20120403201221.ovff4aabtwwcoco0@webmail.int.intellilink.co.jp>
References: <20120403094840.ftxlwztl40gwcg4s@webmail.int.intellilink.co.jp>
	<20120403.005428.1951197638640326467.davem@davemloft.net>
	<20120403200834.witdp0frwwo48occ@webmail.int.intellilink.co.jp>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="=_4t2qr314zns4"
Content-Transfer-Encoding: 7bit
Cc: "shemminger@vyatta.com" <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ils-mail01.intellilink.co.jp ([61.115.36.70]:39558 "EHLO
	ils-mail01.intellilink.co.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750838Ab2DCLMX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 07:12:23 -0400
In-Reply-To: <20120403200834.witdp0frwwo48occ@webmail.int.intellilink.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This message is in MIME format.

--=_4t2qr314zns4
Content-Type: text/plain;
	charset=ISO-2022-JP;
	format="flowed"
Content-Disposition: inline
Content-Transfer-Encoding: 7bit



--=_4t2qr314zns4
Content-Type: text/plain;
	charset=ISO-2022-JP;
	name="sysctl-ip_local_port_range-documentation-v2.patch"
Content-Disposition: attachment;
	filename="sysctl-ip_local_port_range-documentation-v2.patch"
Content-Transfer-Encoding: 7bit

diff -urNp linux-3.4-rc1-orig/Documentation/networking/ip-sysctl.txt linux-3.4-rc1/Documentation/networking/ip-sysctl.txt
--- linux-3.4-rc1-orig/Documentation/networking/ip-sysctl.txt	2012-03-19 08:15:34.000000000 +0900
+++ linux-3.4-rc1/Documentation/networking/ip-sysctl.txt	2012-04-03 19:08:59.554903584 +0900
@@ -604,15 +604,8 @@ IP Variables:
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
 
 ip_local_reserved_ports - list of comma separated ranges
 	Specify the ports which are reserved for known third-party

--=_4t2qr314zns4--
