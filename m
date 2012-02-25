From: pablo@netfilter.org
Subject: [PATCH 0/3] netlink: netlink_dump_start takes pointer to data
Date: Sat, 25 Feb 2012 01:30:14 +0100
Message-ID: <1330129817-28199-1-git-send-email-pablo@netfilter.org>
Cc: netfilter-devel@vger.kernel.org, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

Hi!

This is the second version of the extension for netlink_dump_start
to take one data pointer that can be pass to the dump callback.

These changes allow to filter by the ctmark in ctnetlink.

Suggestion from Davem has been included in this patchset.

Thanks!

Pablo Neira Ayuso (3):
  netlink: add netlink_dump_control structure for netlink_dump_start()
  netlink: allow to pass data pointer to netlink_dump_start() callback
  netfilter: ctnetlink: support kernel-space dump filtering by ctmark

 crypto/crypto_user.c                          |   10 +++-
 drivers/infiniband/core/netlink.c             |   10 +++-
 include/linux/netfilter/nfnetlink_conntrack.h |    1 +
 include/linux/netlink.h                       |   12 ++++-
 net/core/rtnetlink.c                          |    9 +++-
 net/ipv4/inet_diag.c                          |   18 ++++++---
 net/netfilter/ipset/ip_set_core.c             |   10 +++-
 net/netfilter/nf_conntrack_netlink.c          |   50 ++++++++++++++++++++++---
 net/netfilter/nfnetlink_acct.c                |    6 ++-
 net/netlink/af_netlink.c                      |   12 ++---
 net/netlink/genetlink.c                       |    9 +++-
 net/unix/diag.c                               |   10 +++--
 net/xfrm/xfrm_user.c                          |    9 +++-
 13 files changed, 123 insertions(+), 43 deletions(-)

-- 
1.7.7.3

