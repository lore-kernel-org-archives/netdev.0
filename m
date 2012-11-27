From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: [PATCH 0/1] Introduce notification events for routing changes
Date: Tue, 27 Nov 2012 21:27:24 +0100
Message-ID: <1354048045-17846-1-git-send-email-kadlec@blackhole.kfki.hu>
Cc: netfilter-devel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

Please consider applying the following patch for net-next, which introduce
events for routing changes. With it, the MASQUERADE target is able to clean
up connections with wrong NATed source addresses after routing changed (backup
default route, VPNs).

Best regards,
Jozsef

Jozsef Kadlecsik (1):
  Introduce notification events for routing changes

 include/linux/inetdevice.h |    2 ++
 include/linux/netdevice.h  |    1 +
 include/net/ip6_route.h    |    3 ++-
 net/ipv4/fib_trie.c        |   17 +++++++++++++++++
 net/ipv6/route.c           |   21 +++++++++++++++++++++
 5 files changed, 43 insertions(+), 1 deletions(-)

