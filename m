From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 0/4] net: allow setting congctl via routing table
Date: Fri,  5 Dec 2014 16:24:48 +0100
Message-ID: <1417793092-6263-1-git-send-email-dborkman@redhat.com>
Cc: hannes@stressinduktion.org, fw@strlen.de, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51938 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751439AbaLEPZf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Dec 2014 10:25:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the second part of our work and allows for setting the congestion
control algorithm via routing table. For details, please see individual
patches.

Joint work with Florian Westphal, suggested by Hannes Frederic Sowa.

Thanks!

Daniel Borkmann (4):
  net: tcp: refactor reinitialization of congestion control
  net: tcp: add key management to congestion control
  net: tcp: add RTAX_CC_ALGO fib handling
  net: tcp: add per route congestion control

 include/net/inet_connection_sock.h |  3 +-
 include/net/tcp.h                  | 22 +++++++++-
 include/uapi/linux/rtnetlink.h     |  2 +
 net/core/rtnetlink.c               | 15 ++++++-
 net/decnet/dn_fib.c                |  3 +-
 net/decnet/dn_table.c              |  3 +-
 net/ipv4/fib_semantics.c           | 14 +++++-
 net/ipv4/tcp_cong.c                | 87 ++++++++++++++++++++++++++++++++------
 net/ipv4/tcp_ipv4.c                |  2 +
 net/ipv4/tcp_minisocks.c           | 30 +++++++++++--
 net/ipv4/tcp_output.c              | 21 +++++++++
 net/ipv6/ip6_fib.c                 | 15 ++++++-
 net/ipv6/route.c                   |  3 +-
 net/ipv6/tcp_ipv6.c                |  2 +
 14 files changed, 196 insertions(+), 26 deletions(-)

-- 
1.7.11.7
