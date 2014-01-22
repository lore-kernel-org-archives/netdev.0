From: Sharat Masetty <sharat04@gmail.com>
Subject: IPV6 routing problem
Date: Tue, 21 Jan 2014 18:41:58 -0700
Message-ID: <CAJzFV37rPo6trvCwWyErchen_MvTzqabSU+BE3JZjNXT5-5H7Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f174.google.com ([209.85.128.174]:60384 "EHLO
	mail-ve0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751856AbaAVBl6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 20:41:58 -0500
Received: by mail-ve0-f174.google.com with SMTP id pa12so2050655veb.19
        for <netdev@vger.kernel.org>; Tue, 21 Jan 2014 17:41:58 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 I have an IPV6 routing problem that has only surfaced on a 3.10
kernel version. This problem is not seen on 3.4 kernel. I will keep
the problem statement as brief as possible.

I have two interfaces say eth0 and eth1. I have a host route to a
destination over eth1, but this route has a global gateway
address(via) of the router on the link. When this global gateway is
present in the route, the kernel does not seem to pick up the route,
but falls back to the default route which is eth0. When this gateway
is removed from the route or if the gateway is changed to a link local
address of the router, instead of the global address, then routing
seems to work as expected and kernel picks up interface eth1.

== does not work ==
<dest-addr> via <global scope -gateway addr>dev eth1 metric 1024
<global scope -gateway addr> dev eth1  metric 1024

I checked the git commits diff between 3.4 and 3.10 for ipv6/route.c
and ipv6/ip6_fib.c, but looks like they are close to an year apart
with lots of changes. Hence I wanted to reach out to you to see if any
recent changes in IPV6 routing is causing this difference in behavior.

Any help would be greatly appreciated.

Thanks
Sharat
