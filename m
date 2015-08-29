From: Konstantin Shemyak <konstantin@shemyak.com>
Subject: [PATCH iproute2 v3] add 'vti'/'vti6' tunnel modes to ip-tunnel
 manual page
Date: Sat, 29 Aug 2015 21:36:32 +0300
Message-ID: <20150829213632.998f062fbc88b16c24757a92@shemyak.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hapkido.dreamhost.com ([66.33.216.122]:51582 "EHLO
	hapkido.dreamhost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752736AbbH2Sgi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2015 14:36:38 -0400
Received: from homiemail-a23.g.dreamhost.com (sub3.mail.dreamhost.com [69.163.253.7])
	by hapkido.dreamhost.com (Postfix) with ESMTP id 73530C1F4B
	for <netdev@vger.kernel.org>; Sat, 29 Aug 2015 11:36:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* "vti" and "vti6" tunnel modes added to ip-tunnel.8 manual page
* Added "hoplimit" terminology for IPv6
* Corrected usage line
* Minor language fix
---
 man/man8/ip-tunnel.8 | 24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/man/man8/ip-tunnel.8 b/man/man8/ip-tunnel.8
index c97c28c..8b746cb 100644
--- a/man/man8/ip-tunnel.8
+++ b/man/man8/ip-tunnel.8
@@ -6,14 +6,12 @@ ip-tunnel - tunnel configuration
 .ad l
 .in +8
 .ti -8
-.B ip
-.RI "[ " OPTIONS " ]"
-.B tunnel
-.RI " { " COMMAND " | "
-.BR help " }"
+.B ip tunnel help
 .sp
 .ti -8
-.BR "ip tunnel" " { " add " | " change " | " del " | " show " | " prl " }"
+.BR "ip "
+.RI "[ " OPTIONS " ]"
+.BR "tunnel" " { " add " | " change " | " del " | " show " | " prl " }"
 .RI "[ " NAME " ]"
 .br
 .RB "[ " mode
@@ -29,7 +27,7 @@ ip-tunnel - tunnel configuration
 .br
 .RB "[ " encaplimit
 .IR ELIM " ]"
-.RB "[ " ttl
+.RB "[ " ttl "|" hoplimit
 .IR TTL " ]"
 .br
 .RB "[ " tos
@@ -50,7 +48,7 @@ ip-tunnel - tunnel configuration
 
 .ti -8
 .IR MODE " := "
-.RB " { " ipip " | " gre " | " sit " | " isatap " | " ip6ip6 " | " ipip6 " | " ip6gre " | " any " }"
+.RB " { " ipip " | " gre " | " sit " | " isatap " | " vti " | " ip6ip6 " | " ipip6 " | " ip6gre " | " vti6 " | " any " }"
 
 .ti -8
 .IR ADDR " := { " IP_ADDRESS " |"
@@ -107,10 +105,10 @@ select the tunnel device name.
 set the tunnel mode. Available modes depend on the encapsulating address family.
 .br
 Modes for IPv4 encapsulation available:
-.BR ipip ", " sit ", " isatap " and " gre "."
+.BR ipip ", " sit ", " isatap ", " vti ", and " gre "."
 .br
 Modes for IPv6 encapsulation available:
-.BR ip6ip6 ", " ipip6 ", " ip6gre ", and " any "."
+.BR ip6ip6 ", " ipip6 ", " ip6gre ", " vti6 ", and " any "."
 
 .TP
 .BI remote " ADDRESS"
@@ -123,7 +121,9 @@ It must be an address on another interface of this host.
 
 .TP
 .BI ttl " N"
-set a fixed TTL
+.TP
+.BI hoplimit " N"
+set a fixed TTL (IPv4) or hoplimit (IPv6)
 .I N
 on tunneled packets.
 .I N
@@ -218,7 +218,7 @@ The
 .B  seq
 flag is equivalent to the combination
 .BR "iseq oseq" .
-.B It isn't work. Don't use it.
+.B It doesn't work. Don't use it.
 
 .TP
 .BI encaplim " ELIM"
-- 
1.9.1
