From: Jan Engelhardt <jengelh@computergmbh.de>
Subject: [NET]: Sink IPv6 options into its own submenu
Date: Mon, 31 Mar 2008 11:47:13 +0200 (CEST)
Message-ID: <alpine.LNX.1.10.0803311145520.2554@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:45232 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753638AbYCaJrP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2008 05:47:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit f5f678a6a9f0b83b5babf9a8954a49de09d45842
Author: Jan Engelhardt <jengelh@computergmbh.de>
Date:   Mon Mar 31 11:44:02 2008 +0200

     [NET]: Sink IPv6 menuconfig options into its own submenu

     Signed-off-by: Jan Engelhardt <jengelh@computergmbh.de>
---
  net/ipv6/Kconfig |   23 ++++++++---------------
  1 files changed, 8 insertions(+), 15 deletions(-)

diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
index 47263e4..c8b6ca9 100644
--- a/net/ipv6/Kconfig
+++ b/net/ipv6/Kconfig
@@ -3,7 +3,7 @@
  #

  #   IPv6 as module will cause a CRASH if you try to unload it
-config IPV6
+menuconfig IPV6
  	tristate "The IPv6 protocol"
  	default m
  	---help---
@@ -19,9 +19,10 @@ config IPV6
  	  To compile this protocol support as a module, choose M here: the
  	  module will be called ipv6.

+if IPV6
+
  config IPV6_PRIVACY
  	bool "IPv6: Privacy Extensions support"
-	depends on IPV6
  	---help---
  	  Privacy Extensions for Stateless Address Autoconfiguration in IPv6
  	  support.  With this option, additional periodically-alter 
@@ -40,7 +41,6 @@ config IPV6_PRIVACY

  config IPV6_ROUTER_PREF
  	bool "IPv6: Router Preference (RFC 4191) support"
-	depends on IPV6
  	---help---
  	  Router Preference is an optional extension to the Router
  	  Advertisement message to improve the ability of hosts
@@ -59,7 +59,7 @@ config IPV6_ROUTE_INFO

  config IPV6_OPTIMISTIC_DAD
  	bool "IPv6: Enable RFC 4429 Optimistic DAD (EXPERIMENTAL)"
-	depends on IPV6 && EXPERIMENTAL
+	depends on EXPERIMENTAL
  	---help---
  	  This is experimental support for optimistic Duplicate
  	  Address Detection.  It allows for autoconfigured addresses
@@ -69,7 +69,6 @@ config IPV6_OPTIMISTIC_DAD

  config INET6_AH
  	tristate "IPv6: AH transformation"
-	depends on IPV6
  	select XFRM
  	select CRYPTO
  	select CRYPTO_HMAC
@@ -82,7 +81,6 @@ config INET6_AH

  config INET6_ESP
  	tristate "IPv6: ESP transformation"
-	depends on IPV6
  	select XFRM
  	select CRYPTO
  	select CRYPTO_AUTHENC
@@ -98,7 +96,6 @@ config INET6_ESP

  config INET6_IPCOMP
  	tristate "IPv6: IPComp transformation"
-	depends on IPV6
  	select XFRM
  	select INET6_XFRM_TUNNEL
  	select CRYPTO
@@ -111,7 +108,7 @@ config INET6_IPCOMP

  config IPV6_MIP6
  	tristate "IPv6: Mobility (EXPERIMENTAL)"
-	depends on IPV6 && EXPERIMENTAL
+	depends on EXPERIMENTAL
  	select XFRM
  	---help---
  	  Support for IPv6 Mobility described in RFC 3775.
@@ -129,7 +126,6 @@ config INET6_TUNNEL

  config INET6_XFRM_MODE_TRANSPORT
  	tristate "IPv6: IPsec transport mode"
-	depends on IPV6
  	default IPV6
  	select XFRM
  	---help---
@@ -139,7 +135,6 @@ config INET6_XFRM_MODE_TRANSPORT

  config INET6_XFRM_MODE_TUNNEL
  	tristate "IPv6: IPsec tunnel mode"
-	depends on IPV6
  	default IPV6
  	select XFRM
  	---help---
@@ -149,7 +144,6 @@ config INET6_XFRM_MODE_TUNNEL

  config INET6_XFRM_MODE_BEET
  	tristate "IPv6: IPsec BEET mode"
-	depends on IPV6
  	default IPV6
  	select XFRM
  	---help---
@@ -159,14 +153,13 @@ config INET6_XFRM_MODE_BEET

  config INET6_XFRM_MODE_ROUTEOPTIMIZATION
  	tristate "IPv6: MIPv6 route optimization mode (EXPERIMENTAL)"
-	depends on IPV6 && EXPERIMENTAL
+	depends on EXPERIMENTAL
  	select XFRM
  	---help---
  	  Support for MIPv6 route optimization mode.

  config IPV6_SIT
  	tristate "IPv6: IPv6-in-IPv4 tunnel (SIT driver)"
-	depends on IPV6
  	select INET_TUNNEL
  	default y
  	---help---
@@ -181,7 +174,6 @@ config IPV6_SIT
  config IPV6_TUNNEL
  	tristate "IPv6: IP-in-IPv6 tunnel (RFC2473)"
  	select INET6_TUNNEL
-	depends on IPV6
  	---help---
  	  Support for IPv6-in-IPv6 and IPv4-in-IPv6 tunnels described in
  	  RFC 2473.
@@ -190,7 +182,7 @@ config IPV6_TUNNEL

  config IPV6_MULTIPLE_TABLES
  	bool "IPv6: Multiple Routing Tables"
-	depends on IPV6 && EXPERIMENTAL
+	depends on EXPERIMENTAL
  	select FIB_RULES
  	---help---
  	  Support multiple routing tables.
@@ -209,3 +201,4 @@ config IPV6_SUBTREES

  	  If unsure, say N.

+endif # IPV6

