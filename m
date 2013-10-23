From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next 0/3] initialize fragment hash secrets with net_get_random_once
Date: Wed, 23 Oct 2013 11:06:54 +0200
Message-ID: <1382519217-750-1-git-send-email-hannes@stressinduktion.org>
Cc: netfilter-devel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

This series switches the inet_frag.rnd hash initialization to
net_get_random_once.

Included patches:
 ipv4: initialize ip4_frags hash secret as late
 ipv6: split inet6_hash_frag for netfilter and
 inet: remove old fragmentation hash initializing

Diffstat:
 include/net/inet_frag.h                 |  4 ++++
 include/net/ipv6.h                      |  2 --
 net/ipv4/inet_fragment.c                |  3 ---
 net/ipv4/ip_fragment.c                  |  1 +
 net/ipv6/netfilter/nf_conntrack_reasm.c | 16 ++++++++++++++--
 net/ipv6/reassembly.c                   | 12 ++++++------
 6 files changed, 25 insertions(+), 13 deletions(-)

Greetings,

  Hannes

