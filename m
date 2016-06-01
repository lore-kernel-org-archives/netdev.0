From: Peter Heise <mail@pheise.de>
Subject: [PATCH iproute2] man: ip-link: Added HSR part
Date: Wed, 1 Jun 2016 09:43:15 +0200
Message-ID: <20160601074315.GA34365@aircraft-controller>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: peter.heise@airbus.com
To: stephen@networkplumber.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pheise.de ([81.88.24.24]:40494 "EHLO ghost.pheise.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750697AbcFAHnR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Jun 2016 03:43:17 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added HSR part to manpage as follow-up to last commit's
feedback.

Signed-off-by: Peter Heise <peter.heise@airbus.com>
---
 man/man8/ip-link.8.in | 33 +++++++++++++++++++++++++++++++++
 1 file changed, 33 insertions(+)

diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index d3881e5..7aeb5f4 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -846,6 +846,39 @@ forces the underlying interface into promiscuous mode. Passing the
 using standard tools.
 .in -8
 
+.TP
+High-availability Seamless Redundancy (HSR) Support
+For a link of type
+.I HSR
+the following additional arguments are supported:
+
+.BI "ip link add link " DEVICE " name " NAME
+.BI type " hsr "
+.BI slave1 " SLAVE1-IF " slave2 " SLAVE2-IF "
+.BR " [ supervision " ADDR-BYTE "  ] "
+.BR " [ version  { " 0 " | " 1 " } ] "
+
+.in +8
+.sp
+.BR type " hsr "
+- specifies the link type to use, here HSR.
+
+.BI slave1 " SLAVE1-IF "
+- Specifies the physical device used for the first of the two ring ports.
+
+.BI slave2 " SLAVE2-IF "
+- Specifies the physical device used for the second of the two ring ports.
+
+.BR "supervision ADDR-BYTE "
+- The last byte of the multicast address used for HSR supervision frames. 
+Default option is "0", possible values 0-255.
+
+.BR "version { 0 | 1 }"
+- Selects the protocol version of the interface. Default option is "0", which 
+corresponds to the 2010 version of the HSR standard. Option "1" activates the 
+2012 version.
+.in -8
+
 .SS ip link delete - delete virtual link
 
 .TP
-- 
2.7.4
