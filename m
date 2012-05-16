From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 0/2] net/ipv4 and net/ipv6 logging cleanups
Date: Tue, 15 May 2012 17:11:52 -0700
Message-ID: <cover.1337126962.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joe Perches (2):
  net: ipv6: Standardize prefixes for message logging
  net: ipv4 and ipv6: Convert printk(KERN_DEBUG to pr_debug

 net/ipv4/ah4.c                |    4 +-
 net/ipv4/arp.c                |    9 +++--
 net/ipv4/devinet.c            |    5 +--
 net/ipv4/inet_timewait_sock.c |    4 +-
 net/ipv4/route.c              |    9 ++---
 net/ipv4/tcp_input.c          |   48 ++++++++++++++--------------
 net/ipv4/tcp_output.c         |    4 ++-
 net/ipv6/addrconf.c           |   68 ++++++++++++++++++-----------------------
 net/ipv6/addrlabel.c          |    2 +-
 net/ipv6/af_inet6.c           |   14 +++-----
 net/ipv6/ah6.c                |   16 +++++----
 net/ipv6/esp6.c               |   14 +++++---
 net/ipv6/icmp.c               |    8 ++--
 net/ipv6/ip6_fib.c            |   25 ++++++++-------
 net/ipv6/ip6_tunnel.c         |   23 ++++++-------
 net/ipv6/ip6mr.c              |    2 +-
 net/ipv6/ipcomp6.c            |   15 +++++---
 net/ipv6/mcast.c              |    3 +-
 net/ipv6/mip6.c               |   30 +++++++++---------
 net/ipv6/ndisc.c              |   22 +++++--------
 net/ipv6/route.c              |    8 +++--
 net/ipv6/sit.c                |    6 ++-
 net/ipv6/tunnel6.c            |   10 +++--
 23 files changed, 173 insertions(+), 176 deletions(-)

-- 
1.7.8.111.gad25c.dirty
