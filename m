From: pablo@netfilter.org
Subject: [PATCH 0/2] more Netfilter fixes for 3.2-rc7
Date: Sat, 31 Dec 2011 17:22:45 +0100
Message-ID: <1325348567-4251-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

Hi Dave,

The following patches are a couple of late fixes for Netfilter,
one for IPVS and another for ctnetlink.

You can pull them from:

git://1984.lsi.us.es/net nf

Julian Anastasov (1):
  ipvs: try also real server with port 0 in backup server

Xi Wang (1):
  netfilter: ctnetlink: fix timeout calculation

 include/net/ip_vs.h                  |    2 +-
 net/netfilter/ipvs/ip_vs_conn.c      |    2 +-
 net/netfilter/ipvs/ip_vs_ctl.c       |   10 ++++++++--
 net/netfilter/ipvs/ip_vs_sync.c      |    2 +-
 net/netfilter/nf_conntrack_netlink.c |    4 ++--
 5 files changed, 13 insertions(+), 7 deletions(-)

-- 
1.7.7.3

