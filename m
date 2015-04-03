From: Ian Morris <ipm@chirality.org.uk>
Subject: [PATCH net-next 0/2] ipv4: coding style - comparisons with NULL
Date: Fri,  3 Apr 2015 09:17:25 +0100
Message-ID: <1428049047-14783-1-git-send-email-ipm@chirality.org.uk>
Cc: Ian Morris <ipm@chirality.org.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from inet-gw.chirality.org.uk ([88.97.209.22]:48372 "EHLO
	yew.chirality.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752107AbbDCIRi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2015 04:17:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Per the suggestion of Joe Perches, attached is a patch which aligns the
coding style in ipv4 for comparisons with NULL.

The code uses multiple different styles when comparing with NULL (I.e. 
x == NULL and !x as well as x != NULL and x). Generally the latter form
is preferred in netdev and so this changes aligns the code to this style.

Ian Morris (2):
  ipv4: coding style: comparison for equality with NULL
  ipv4: coding style: comparison for inequality with NULL

 net/ipv4/af_inet.c              |  8 +++----
 net/ipv4/arp.c                  | 28 +++++++++++------------
 net/ipv4/cipso_ipv4.c           | 42 +++++++++++++++++-----------------
 net/ipv4/devinet.c              | 42 +++++++++++++++++-----------------
 net/ipv4/esp4.c                 |  2 +-
 net/ipv4/fib_frontend.c         | 26 ++++++++++-----------
 net/ipv4/fib_rules.c            |  4 ++--
 net/ipv4/fib_semantics.c        | 24 ++++++++++----------
 net/ipv4/fib_trie.c             | 12 +++++-----
 net/ipv4/geneve.c               |  4 ++--
 net/ipv4/gre_offload.c          |  4 ++--
 net/ipv4/icmp.c                 |  6 ++---
 net/ipv4/igmp.c                 | 20 ++++++++---------
 net/ipv4/inet_connection_sock.c |  8 +++----
 net/ipv4/inet_fragment.c        |  4 ++--
 net/ipv4/inet_hashtables.c      |  2 +-
 net/ipv4/inet_timewait_sock.c   |  2 +-
 net/ipv4/ip_fragment.c          | 14 +++++++-----
 net/ipv4/ip_gre.c               |  4 ++--
 net/ipv4/ip_input.c             |  7 +++---
 net/ipv4/ip_options.c           |  2 +-
 net/ipv4/ip_output.c            | 29 +++++++++++++-----------
 net/ipv4/ip_sockglue.c          |  6 ++---
 net/ipv4/ip_tunnel.c            | 10 ++++-----
 net/ipv4/ip_vti.c               |  2 +-
 net/ipv4/ipcomp.c               |  2 +-
 net/ipv4/ipconfig.c             |  6 +++--
 net/ipv4/ipip.c                 |  2 +-
 net/ipv4/ipmr.c                 | 50 ++++++++++++++++++++---------------------
 net/ipv4/ping.c                 |  4 ++--
 net/ipv4/raw.c                  |  6 ++---
 net/ipv4/route.c                | 22 +++++++++---------
 net/ipv4/sysctl_net_ipv4.c      |  6 ++---
 net/ipv4/tcp.c                  | 14 ++++++------
 net/ipv4/tcp_diag.c             |  2 +-
 net/ipv4/tcp_fastopen.c         |  6 ++---
 net/ipv4/tcp_input.c            | 28 +++++++++++------------
 net/ipv4/tcp_ipv4.c             | 10 ++++-----
 net/ipv4/tcp_metrics.c          |  2 +-
 net/ipv4/tcp_minisocks.c        |  8 +++----
 net/ipv4/tcp_output.c           | 35 +++++++++++++++--------------
 net/ipv4/udp.c                  | 10 ++++-----
 net/ipv4/udp_diag.c             |  2 +-
 net/ipv4/udp_offload.c          |  4 ++--
 net/ipv4/xfrm4_input.c          |  2 +-
 net/ipv4/xfrm4_policy.c         |  2 +-
 46 files changed, 272 insertions(+), 263 deletions(-)

-- 
1.9.1
