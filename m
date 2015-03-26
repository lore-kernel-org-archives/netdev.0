From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: [RFC net-next/iproute2 0/2] net: infrastructure to support RFC-5549
Date: Thu, 26 Mar 2015 17:05:26 -0400
Message-ID: <1427403928-1342-1-git-send-email-gospo@cumulusnetworks.com>
To: netdev@vger.kernel.org, Bjornar Ness <bjornar.ness@gmail.com>,
	Sowmini Varadhan <sowmini05@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f49.google.com ([209.85.213.49]:34838 "EHLO
	mail-yh0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752298AbbCZVGb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 17:06:31 -0400
Received: by yhim52 with SMTP id m52so32152079yhi.2
        for <netdev@vger.kernel.org>; Thu, 26 Mar 2015 14:06:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As promised here is the series for adding the needed kernel and netlink 
support to enable support for RFC-5549 in Linux.  Changes to quagga,
bird, or any other routing daemon would be needed for full RFC-5549
support, but without this (or similar) no support for thie RFC is
possible.  This is an RFC series, so any feedback is greatly
appreciated -- including discussions on the value of an implementation
that seems a bit like a hack!

Andy Gospodarek (1):
  net: add support for ipv6 nexthops for ipv4 routes

 include/net/ip_fib.h           |  3 +++
 include/net/route.h            |  2 ++
 include/uapi/linux/rtnetlink.h |  1 +
 net/ipv4/fib_frontend.c        |  4 ++++
 net/ipv4/fib_semantics.c       | 24 +++++++++++++++++++-----
 net/ipv4/ip_output.c           | 30 +++++++++++++++++++++++++-----
 net/ipv4/route.c               | 12 ++++++++++++
 7 files changed, 66 insertions(+), 10 deletions(-)

Andy Gospodarek (1):
  iproute2: experimental support for setting IPv6 nexthop on IPv4 route

 include/linux/rtnetlink.h |  4 ++++
 ip/iproute.c              | 18 +++++++++++++++---
 lib/utils.c               |  4 +++-
 3 files changed, 22 insertions(+), 4 deletions(-)

-- 
1.9.3
