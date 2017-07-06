From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/2] Netfilter fixes for net
Date: Thu,  6 Jul 2017 14:54:23 +0200
Message-ID: <1499345665-7428-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following patchset contains two Netfilter fixes for your net tree,
they are:

1) Fix memleak from netns release path of conntrack protocol trackers,
   patch from Liping Zhang.

2) Uninitialized flags field in ebt_log, that results in unpredictable
   logging format in ebtables, also from Liping.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Thanks a lot!

----------------------------------------------------------------

The following changes since commit e20bd60bf62a2448be873653c7febca1d4d73afc:

  net: usb: asix88179_178a: Add support for the Belkin B2B128 (2017-06-27 15:46:07 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git HEAD

for you to fetch changes up to 91af6ba7ff16bd7e5919aedfe70aad73a3375619:

  netfilter: ebt_nflog: fix unexpected truncated packet (2017-06-29 18:47:02 +0200)

----------------------------------------------------------------
Liping Zhang (2):
      netfilter: nf_ct_dccp/sctp: fix memory leak after netns cleanup
      netfilter: ebt_nflog: fix unexpected truncated packet

 net/bridge/netfilter/ebt_nflog.c        | 1 +
 net/netfilter/nf_conntrack_proto_dccp.c | 7 +++++++
 net/netfilter/nf_conntrack_proto_sctp.c | 7 +++++++
 3 files changed, 15 insertions(+)
