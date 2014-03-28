From: Wangyufen <wangyufen@huawei.com>
Subject: [PATCH net-next v5 0/3] ipv6: tcp_ipv6 policy route issue
Date: Fri, 28 Mar 2014 17:20:24 +0800
Message-ID: <1395998427-7532-1-git-send-email-wangyufen@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kuznet@ms2.inr.ac.ru>, Wang Yufen <wangyufen@huawei.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:21452 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750924AbaC1JUr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 05:20:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Yufen <wangyufen@huawei.com>

Wang Yufen (3):
  ipv6: tcp_ipv6 do some cleanup
  ipv6: reuse rt6_need_strict
  ipv6: tcp_ipv6 policy route issue

v4: use rt6_need_strict to check whether the oif directly
    assigned to iif
v5: Move the whole rt6_need_strict as static inline into 
    ip6_route.h, instade of just delete static.

 include/net/ip6_route.h | 5 +++++
 net/ipv6/route.c        | 6 ------
 net/ipv6/ip6_fib.c | 42 +++---
 3 file changed, 27 insertions(+), 26 deletions(-)

 -- 
1.7.12
