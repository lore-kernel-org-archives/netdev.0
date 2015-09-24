From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 3/3] l2tp: remove references to modprobe in documentation
Date: Wed, 23 Sep 2015 21:33:36 -0700
Message-ID: <20150924043503.713401180@networkplumber.org>
References: <20150924043333.231895827@networkplumber.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: jchapman@katalix.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:32883 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751044AbbIXEev (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 00:34:51 -0400
Received: by pacex6 with SMTP id ex6so60871611pac.0
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 21:34:51 -0700 (PDT)
Content-Disposition: inline; filename=l2tp-doc-modprobe.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No longer need explicit modprobe's and update to use ip instead
of deprecated ifconfig command.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/Documentation/networking/l2tp.txt	2015-05-21 15:13:01.421115881 -0700
+++ b/Documentation/networking/l2tp.txt	2015-09-07 12:18:07.672921513 -0700
@@ -213,15 +213,12 @@ To create an L2TPv3 ethernet pseudowire
 and peer 192.168.1.2, using IP addresses 10.5.1.1 and 10.5.1.2 for the
 tunnel endpoints:-
 
-# modprobe l2tp_eth
-# modprobe l2tp_netlink
-
 # ip l2tp add tunnel tunnel_id 1 peer_tunnel_id 1 udp_sport 5000 \
   udp_dport 5000 encap udp local 192.168.1.1 remote 192.168.1.2
 # ip l2tp add session tunnel_id 1 session_id 1 peer_session_id 1
-# ifconfig -a
+# ip -s -d show dev l2tpeth0
 # ip addr add 10.5.1.2/32 peer 10.5.1.1/32 dev l2tpeth0
-# ifconfig l2tpeth0 up
+# ip li set dev l2tpeth0 up
 
 Choose IP addresses to be the address of a local IP interface and that
 of the remote system. The IP addresses of the l2tpeth0 interface can be
