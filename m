From: Jiri Pirko <jpirko@redhat.com>
Subject: [RFC] IPv6 route replacement
Date: Wed, 22 Jul 2009 11:50:41 +0200
Message-ID: <20090722095040.GC3517@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, pekkas@netcore.fi, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:58441 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751424AbZGVJuz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jul 2009 05:50:55 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello guys.

I would like to hear your opinion on the following:

[root@f11 ~]# ip -6 route list 3ffe::1:1
[root@f11 ~]# ip -6 route add 3ffe::1:1 via fe80::20c:29ff:fe4c:3108 dev eth0 metric 1024
[root@f11 ~]# ip -6 route list 3ffe::1:1
3ffe::1:1 via fe80::20c:29ff:fe4c:3108 dev eth0  metric 1024  mtu 1500 advmss 1440 hoplimit 4294967295
[root@f11 ~]# ip -6 route change 3ffe::1:1 via fe80::20c:29ff:fe4c:3108 dev eth0 metric 100
[root@f11 ~]# ip -6 route list 3ffe::1:1
3ffe::1:1 via fe80::20c:29ff:fe4c:3108 dev eth0  metric 100  mtu 1500 advmss 1440 hoplimit 4294967295
3ffe::1:1 via fe80::20c:29ff:fe4c:3108 dev eth0  metric 1024  mtu 1500 advmss 1440 hoplimit 4294967295
[root@f11 ~]#

Now do you think this is the right behaviour? I would expect the first route to
be replaced. The same result is when you do "ip -6 route replace"

Thanks

Jirka
