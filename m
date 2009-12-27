From: Jeremy Jackson <jerj@coplanar.net>
Subject: querying TOS/DSCP at accept() time?
Date: Sun, 27 Dec 2009 09:57:32 -0500
Message-ID: <1261925852.8193.9.camel@ragnarok>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from titan.coplanar.net ([70.47.139.2]:46673 "EHLO
	titan.coplanar.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751991AbZL0O5m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Dec 2009 09:57:42 -0500
Received: from [70.47.139.174] (ragnarok.coplanar.net [70.47.139.174] (may be forged))
	(authenticated bits=0)
	by titan.coplanar.net (8.14.2/8.14.2/Debian-2build1) with ESMTP id nBREveHE025399
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Sun, 27 Dec 2009 09:57:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I would like to allow clients connecting to webserver to choose TOS/DSCP
value they want in reply packets, based on TOS setting received by
webserver in initial SYN-SYN/ACK-ACK exchange.  Linux samples the TOS
byte of the ACK that moves the state to CONNECTED, presumably to use for
later ECN processing, but I cannot find a way to get this from
userspace.

net/ipv4/tcp_ipv4.c:1645
    TCP_SKB_CB(skb)->flags   = iph->tos;


Am I missing something in getsockopt(TCP_INFO perhaps?) or accept(), or
is this currently not possible?



-- 
Jeremy Jackson
Coplanar Networks
(519)489-4903
http://www.coplanar.net
jerj@coplanar.net

