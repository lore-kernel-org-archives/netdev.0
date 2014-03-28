From: Wangyufen <wangyufen@huawei.com>
Subject: [PATCH net-next v4 0/3] ipv6: tcp_ipv6 policy route issue
Date: Fri, 28 Mar 2014 12:01:40 +0800
Message-ID: <1395979303-7668-1-git-send-email-wangyufen@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ioe@perches.com>, <kuznet@ms2.inr.ac.ru>,
	Wang Yufen <wangyufen@huawei.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:63815 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751733AbaC1EEW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 00:04:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Yufen <wangyufen@huawei.com>

Wang Yufen (3):
  ipv6: tcp_ipv6 do some cleanup
  ipv6: reuse rt6_need_strict
  ipv6: tcp_ipv6 policy route issue

v4: use rt6_need_strict to check whether the oif directly
assigned to iif

 include/net/ip6_route.h | 1 +
 net/ipv6/route.c        | 2 +-
 net/ipv6/ip6_fib.c | 42 +++---
 3 file changed, 24 insertions(+), 21 deletions(-)

 -- 
1.7.12
