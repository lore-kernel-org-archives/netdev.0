From: pablo@netfilter.org
Subject: [PATCH 0/2] netlink: netlink_dump_start takes pointer to data
Date: Fri, 24 Feb 2012 23:14:06 +0100
Message-ID: <1330121648-2956-1-git-send-email-pablo@netfilter.org>
Cc: netfilter-devel@vger.kernel.org, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

Hi,

This patch modifies netlink_dump_start to take a pointer to data.
All caller are modified to use the new interface. This pointer can
be accessed via cb->data from the callback.

The follow-up patch for ctnetlink uses this change to pass the
filter structure, which allows filtering the dump by the ct
mark/mask.

Let me know if you are OK with this change, I can included it
in the next netfilter update or you may want to directly apply
it.

Thanks!

Pablo Neira Ayuso (2):
  netlink: netlink_dump_start may take data pointer for callbacks
  netfilter: ctnetlink: support kernel-space dump filterings

 crypto/crypto_user.c                          |    2 +-
 drivers/infiniband/core/netlink.c             |    2 +-
 include/linux/netfilter/nfnetlink_conntrack.h |    1 +
 include/linux/netlink.h                       |    2 +
 net/core/rtnetlink.c                          |    2 +-
 net/ipv4/inet_diag.c                          |    4 +-
 net/netfilter/ipset/ip_set_core.c             |    2 +-
 net/netfilter/nf_conntrack_netlink.c          |   37 +++++++++++++++++++++++--
 net/netfilter/nfnetlink_acct.c                |    2 +-
 net/netlink/af_netlink.c                      |    2 +
 net/netlink/genetlink.c                       |    2 +-
 net/unix/diag.c                               |    2 +-
 net/xfrm/xfrm_user.c                          |    2 +-
 13 files changed, 49 insertions(+), 13 deletions(-)

-- 
1.7.7.3

