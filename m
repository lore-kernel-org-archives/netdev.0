From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [RFC PATCH net-next v2 0/1] Add support of ECMPv6
Date: Fri, 14 Sep 2012 09:59:07 +0200
Message-ID: <1347609548-14494-1-git-send-email-nicolas.dichtel@6wind.com>
References: <505058F5.9020707@linux-ipv6.org>
Cc: bernat@luffy.cx, netdev@vger.kernel.org, davem@davemloft.net
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:44720 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755187Ab2INH6O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Sep 2012 03:58:14 -0400
In-Reply-To: <505058F5.9020707@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here is a proposal to add the support of ECMPv6. The previous patch
from Vincent against iproute2 can be used, but a little other patch is needed
too, see http://patchwork.ozlabs.org/patch/183277/

If the kernel patch is approved, I will submit formally the patch for
iproute2.

Here is an example of a command to add an ECMP route:
$ ip -6 route add 3ffe:304:124:2306::/64 \
	nexthop via fe80::230:1bff:feb4:e05c dev eth0 weight 1 \
	nexthop via fe80::230:1bff:feb4:dd4f dev eth0 weight 1

v2: rename CONFIG_IPV6_MULTIPATH_ROUTE to CONFIG_IPV6_MULTIPATH_HASH
    use flowlabel in the hash function
    add reference to RFC
    fix a small identation issue
    remove "If unsure, say N." from the help of CONFIG_IPV6_MULTIPATH

Comments are welcome.

Regards,
Nicolas
