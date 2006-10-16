From: Peter Bieringer <pb@bieringer.de>
Subject: Patch to remove masq/NAT in description of IP6_NF_IPTABLES in ipv6/netfilter/Kconfig
Date: Mon, 16 Oct 2006 09:01:25 +0200
Message-ID: <45332E45.10207@bieringer.de>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090702030200020808000006"
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-relay.aerasec.de ([212.18.21.179]:17106 "EHLO
	smtp4.aerasec.de") by vger.kernel.org with ESMTP id S1751484AbWJPHBd
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Oct 2006 03:01:33 -0400
Received: from [IPv6:2001:a60:f011:f101::11] (unknown [IPv6:2001:a60:f011:f101::11])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by smtp4.aerasec.de (Postfix) with ESMTP id D7B74BBE2
	for <netdev@vger.kernel.org>; Mon, 16 Oct 2006 09:01:30 +0200 (CEST)
To: Maillist netdev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090702030200020808000006
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Hi,

afaik, NAT (and therefore masquerading also) is left out by design in
IPv6, looks like a copy&paste issue.

Patch attached to fix this.

	Peter
-- 
Dr. Peter Bieringer                     http://www.bieringer.de/pb/
GPG/PGP Key 0x958F422D                       mailto:pb@bieringer.de
Deep Space 6 Co-Founder and Core Member  http://www.deepspace6.net/

--------------090702030200020808000006
Content-Type: text/x-patch;
 name="Kconfig-netfilter-ipv6.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="Kconfig-netfilter-ipv6.diff"

--- linux-2.6.18.1/net/ipv6/netfilter/Kconfig.orig	2006-10-16 08:56:43.000000000 +0200
+++ linux-2.6.18.1/net/ipv6/netfilter/Kconfig	2006-10-16 08:56:55.000000000 +0200
@@ -40,7 +40,7 @@
 	  To compile it as a module, choose M here.  If unsure, say N.
 
 config IP6_NF_IPTABLES
-	tristate "IP6 tables support (required for filtering/masq/NAT)"
+	tristate "IP6 tables support (required for filtering)"
 	depends on NETFILTER_XTABLES
 	help
 	  ip6tables is a general, extensible packet identification framework.

--------------090702030200020808000006--
