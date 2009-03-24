From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 11/41: xtables: add backward-compat options
Date: Tue, 24 Mar 2009 15:03:21 +0100 (MET)
Message-ID: <20090324140317.31401.63621.sendpatchset@x2.localnet>
References: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34767 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758083AbZCXODY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 10:03:24 -0400
In-Reply-To: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 4323362e49bd10b8ff3fe5cf183fdd52662ff4a3
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Thu Feb 19 11:16:03 2009 +0100

    netfilter: xtables: add backward-compat options
    
    Concern has been expressed about the changing Kconfig options.
    Provide the old options that forward-select.
    
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
index 40ad41f..f8d6180 100644
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -92,6 +92,15 @@ config IP_NF_MATCH_ECN
 
 	  To compile it as a module, choose M here.  If unsure, say N.
 
+config IP_NF_MATCH_TTL
+	tristate '"ttl" match support'
+	depends on NETFILTER_ADVANCED
+	select NETFILTER_XT_MATCH_HL
+	---help---
+	This is a backwards-compat option for the user's convenience
+	(e.g. when running oldconfig). It selects
+	COFNIG_NETFILTER_XT_MATCH_HL.
+
 # `filter', generic and specific targets
 config IP_NF_FILTER
 	tristate "Packet filtering"
@@ -313,6 +322,15 @@ config IP_NF_TARGET_ECN
 
 	  To compile it as a module, choose M here.  If unsure, say N.
 
+config IP_NF_TARGET_TTL
+	tristate '"TTL" target support'
+	depends on NETFILTER_ADVANCED
+	select NETFILTER_XT_TARGET_HL
+	---help---
+	This is a backwards-compat option for the user's convenience
+	(e.g. when running oldconfig). It selects
+	COFNIG_NETFILTER_XT_TARGET_HL.
+
 # raw + specific targets
 config IP_NF_RAW
 	tristate  'raw table support (required for NOTRACK/TRACE)'
diff --git a/net/ipv6/netfilter/Kconfig b/net/ipv6/netfilter/Kconfig
index 4a8d7ec..625353a 100644
--- a/net/ipv6/netfilter/Kconfig
+++ b/net/ipv6/netfilter/Kconfig
@@ -94,6 +94,15 @@ config IP6_NF_MATCH_OPTS
 
 	  To compile it as a module, choose M here.  If unsure, say N.
 
+config IP6_NF_MATCH_HL
+	tristate '"hl" hoplimit match support'
+	depends on NETFILTER_ADVANCED
+	select NETFILTER_XT_MATCH_HL
+	---help---
+	This is a backwards-compat option for the user's convenience
+	(e.g. when running oldconfig). It selects
+	COFNIG_NETFILTER_XT_MATCH_HL.
+
 config IP6_NF_MATCH_IPV6HEADER
 	tristate '"ipv6header" IPv6 Extension Headers Match'
 	default m if NETFILTER_ADVANCED=n
@@ -121,6 +130,15 @@ config IP6_NF_MATCH_RT
 	  To compile it as a module, choose M here.  If unsure, say N.
 
 # The targets
+config IP6_NF_TARGET_HL
+	tristate '"HL" hoplimit target support'
+	depends on NETFILTER_ADVANCED
+	select NETFILTER_XT_TARGET_HL
+	---help---
+	This is a backwards-compat option for the user's convenience
+	(e.g. when running oldconfig). It selects
+	COFNIG_NETFILTER_XT_TARGET_HL.
+
 config IP6_NF_TARGET_LOG
 	tristate "LOG target support"
 	default m if NETFILTER_ADVANCED=n
