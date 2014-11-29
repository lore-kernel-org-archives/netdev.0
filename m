From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] man ip-link: Add description for 'help' command
Date: Sat, 29 Nov 2014 21:49:21 +0200
Message-ID: <1417290561-16970-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f51.google.com ([74.125.82.51]:44225 "EHLO
	mail-wg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751537AbaK2T67 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Nov 2014 14:58:59 -0500
Received: by mail-wg0-f51.google.com with SMTP id k14so11095460wgh.10
        for <netdev@vger.kernel.org>; Sat, 29 Nov 2014 11:58:58 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 man/man8/ip-link.8.in | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index ea23a72..9d4e3da 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -150,6 +150,10 @@ ip-link \- network device configuration
 .B master
 .IR DEVICE " ]"
 
+.ti -8
+.B ip link help
+.RI "[ " TYPE " ]"
+
 .SH "DESCRIPTION"
 .SS ip link add - add virtual link
 
@@ -702,6 +706,12 @@ output statistics with human readable values number followed by suffix
 .BR "\-iec"
 print human readable rates in IEC units (ie. 1K = 1024).
 
+.SS  ip link help - display help
+
+.PP
+.I "TYPE"
+specifies which help of link type to dislpay.
+
 .SH "EXAMPLES"
 .PP
 ip link show
@@ -724,6 +734,11 @@ ip link delete dev eth0.10
 Removes vlan device.
 .RE
 
+ip link help gre
+.RS 4
+Display help for the gre link type.
+.RE
+
 .SH SEE ALSO
 .br
 .BR ip (8)
-- 
2.1.3
