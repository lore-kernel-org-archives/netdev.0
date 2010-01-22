From: Brian Haley <brian.haley@hp.com>
Subject: [PATCH] IPv6: Update documentation for better built-in help with
 params
Date: Fri, 22 Jan 2010 15:24:49 -0500
Message-ID: <4B5A0991.9080701@hp.com>
References: <201001221901.o0MJ1oLk016090@wind.enjellic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: greg@enjellic.com, nhorman@tuxdriver.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:3495 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932116Ab0AVUYy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2010 15:24:54 -0500
In-Reply-To: <201001221901.o0MJ1oLk016090@wind.enjellic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update IPv6 documentation to describe how to set parameters when it's
built-into the kernel.  Reported by <greg@enjellic.com>.

Signed-off-by: Brian Haley <brian.haley@hp.com>
---

diff --git a/Documentation/networking/ipv6.txt b/Documentation/networking/ipv6.txt
index 9fd7e21..d52166b 100644
--- a/Documentation/networking/ipv6.txt
+++ b/Documentation/networking/ipv6.txt
@@ -6,6 +6,10 @@ or modprobe command, but are usually specified in either the
 /etc/modules.conf or /etc/modprobe.conf configuration file, or in a
 distro-specific configuration file.
 
+For cases where IPv6 is built-into the kernel, you can set these
+parameters by specifying them on the kernel command line, for
+example, "ipv6.autoconf=0".
+
 The available ipv6 module parameters are listed below.  If a parameter
 is not specified the default value is used.
 
