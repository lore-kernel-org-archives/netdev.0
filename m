From: David Ahern <dsa@cumulusnetworks.com>
Subject: [RFC net-next 0/4] net: VRF support in IPv6 stack
Date: Mon, 21 Sep 2015 16:32:54 -0700
Message-ID: <1442878378-13322-1-git-send-email-dsa@cumulusnetworks.com>
Cc: shm@cumulusnetworks.com, roopa@cumulusnetworks.com,
	David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:33167 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757385AbbIUXdO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 19:33:14 -0400
Received: by pacex6 with SMTP id ex6so129823880pac.0
        for <netdev@vger.kernel.org>; Mon, 21 Sep 2015 16:33:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Initial support for VRFs in IPv6 stack. Patches apply on top of the L3
Master Device patches sent on Friday:
    http://www.spinics.net/lists/netdev/msg343533.html

All patches can be found here
    github.com/dsahern/linux.git vrf/ipv6-l3mdev-rfc1

David Ahern (4):
  l3mdev: ipv6 support
  net: Remove use of IFF_SLAVE with L3 devices
  net: VRF device: Initial IPv6 support
  net: ipv6: Initial support for VRFs

 drivers/net/vrf.c         | 228 +++++++++++++++++++++++++++++++++++++++++++++-
 include/linux/netdevice.h |   2 +-
 include/net/l3mdev.h      |  43 +++++++++
 net/ipv6/addrconf.c       |   4 +-
 net/ipv6/datagram.c       |   4 +
 net/ipv6/icmp.c           |   6 +-
 net/ipv6/ip6_fib.c        |   1 +
 net/ipv6/ip6_output.c     |   6 +-
 net/ipv6/ndisc.c          |   9 +-
 net/ipv6/route.c          |  17 +++-
 10 files changed, 308 insertions(+), 12 deletions(-)

-- 
1.9.1
