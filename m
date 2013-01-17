From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next (V4) 00/11] IPv6: rt->n (neighbour in rt6_info) removal,
 TAKE 4.
Date: Fri, 18 Jan 2013 07:52:51 +0900
Message-ID: <50F880C3.2050409@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, xiyou.wangcong@gmail.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:44742 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751405Ab3AQWww (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 17:52:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is "TAKE 4" of neighbour removal from rt6_info.

3->4:
- error check in ip6_finish_output2(), in 10/11.

---

YOSHIFUJI Hideaki (11):
  ndisc: Update neigh->updated with write lock.
  ndisc: Remove tbl argument for __ipv6_neigh_lookup().
  ipv6 route: Dump gateway based on RTF_GATEWAY flag and
    rt->rt6i_gateway.
  ndisc: Introduce __ipv6_neigh_lookup_noref().
  ipv6: Do not depend on rt->n in ip6_pol_route().
  ipv6: Do not depend on rt->n in rt6_check_neigh().
  ipv6: Do not depend on rt->n in rt6_probe().
  ipv6: Introduce rt6_nexthop() to select nexthop address.
  ipv6: Do not depend on rt->n in ip6_dst_lookup_tail().
  ipv6: Do not depend on rt->n in ip6_finish_output2().
  ipv6: Complete neighbour entry removal from dst_entry.

 include/net/ip6_fib.h   |    2 -
 include/net/ip6_route.h |    8 +++
 include/net/ndisc.h     |   24 ++++++---
 net/ipv6/ip6_output.c   |   26 ++++++---
 net/ipv6/route.c        |  138 ++++++++++++-----------------------------------
 net/ipv6/xfrm6_policy.c |    1 -
 6 files changed, 76 insertions(+), 123 deletions(-)

-- 
1.7.9.5
