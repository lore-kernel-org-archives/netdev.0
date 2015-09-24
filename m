From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 2/3] l2tp: auto load IP modules
Date: Wed, 23 Sep 2015 21:33:35 -0700
Message-ID: <20150924043502.352796402@networkplumber.org>
References: <20150924043333.231895827@networkplumber.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: jchapman@katalix.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:36802 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750995AbbIXEeu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 00:34:50 -0400
Received: by pacgz1 with SMTP id gz1so11171513pac.3
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 21:34:49 -0700 (PDT)
Content-Disposition: inline; filename=l2tp-ip-alias.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When creating a IP encapsulated tunnel the necessary l2tp module
should be loaded. It already works for UDP encapsulation, it just
doesn't work for direct IP encap.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/net/l2tp/l2tp_ip.c	2015-09-23 21:24:08.644656533 -0700
+++ b/net/l2tp/l2tp_ip.c	2015-09-23 21:24:08.640656514 -0700
@@ -655,3 +655,4 @@ MODULE_VERSION("1.0");
  * enums
  */
 MODULE_ALIAS_NET_PF_PROTO_TYPE(PF_INET, 2, IPPROTO_L2TP);
+MODULE_ALIAS_NET_PF_PROTO(PF_INET, IPPROTO_L2TP);
--- a/net/l2tp/l2tp_ip6.c	2015-09-23 21:24:08.644656533 -0700
+++ b/net/l2tp/l2tp_ip6.c	2015-09-23 21:24:08.640656514 -0700
@@ -801,3 +801,4 @@ MODULE_VERSION("1.0");
  * enums
  */
 MODULE_ALIAS_NET_PF_PROTO_TYPE(PF_INET6, 2, IPPROTO_L2TP);
+MODULE_ALIAS_NET_PF_PROTO(PF_INET6, IPPROTO_L2TP);
