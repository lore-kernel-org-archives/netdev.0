From: Brian Haley <brian.haley@hp.com>
Subject: [PATCH] doc: document IPv6 parameters
Date: Thu, 04 Feb 2010 15:49:44 -0500
Message-ID: <4B6B32E8.6070408@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	greg@enjellic.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:5644 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756653Ab0BDUts (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2010 15:49:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Can you take these in net-next-2.6?  I haven't heard boo from anyone on linux-doc or lkml.

-Brian


Update documentation to describe IPv6 parameters.
Reported by <greg@enjellic.com>.

Signed-off-by: Brian Haley <brian.haley@hp.com>
---

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 736d456..3ca7f8f 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -54,6 +54,7 @@ parameter is applicable:
 	IMA     Integrity measurement architecture is enabled.
 	IOSCHED	More than one I/O scheduler is enabled.
 	IP_PNP	IP DHCP, BOOTP, or RARP is enabled.
+	IPV6	IPv6 support is enabled.
 	ISAPNP	ISA PnP code is enabled.
 	ISDN	Appropriate ISDN support is enabled.
 	JOY	Appropriate joystick support is enabled.
@@ -347,6 +348,9 @@ and is between 256 and 4096 characters. It is defined in the file
 			Change the amount of debugging information output
 			when initialising the APIC and IO-APIC components.
 
+	autoconf=	[IPV6]
+			See Documentation/networking/ipv6.txt.
+
 	show_lapic=	[APIC,X86] Advanced Programmable Interrupt Controller
 			Limit apic dumping. The parameter defines the maximal
 			number of local apics being dumped. Also it is possible
@@ -629,6 +633,12 @@ and is between 256 and 4096 characters. It is defined in the file
 			See drivers/char/README.epca and
 			Documentation/serial/digiepca.txt.
 
+	disable=	[IPV6]
+			See Documentation/networking/ipv6.txt.
+
+	disable_ipv6=	[IPV6]
+			See Documentation/networking/ipv6.txt.
+
 	disable_mtrr_cleanup [X86]
 			The kernel tries to adjust MTRR layout from continuous
 			to discrete, to make X server driver able to add WB

