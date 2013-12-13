From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/2] netfilter fixes for net
Date: Fri, 13 Dec 2013 19:24:57 +0100
Message-ID: <1386959099-24582-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:49736 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752504Ab3LMSZI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Dec 2013 13:25:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patchset contains two Netfilter fixes for your net
tree, they are:

* Fix endianness in nft_reject, the NFTA_REJECT_TYPE netlink attributes
  was not converted to network byte order as needed by all nfnetlink
  subsystems, from Eric Leblond.

* Restrict SYNPROXY target to INPUT and FORWARD chains, this avoid a
  possible crash due to misconfigurations, from Patrick McHardy.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

Thanks!

----------------------------------------------------------------

The following changes since commit 8afdd99a1315e759de04ad6e2344f0c5f17ecb1b:

  udp: ipv4: fix an use after free in __udp4_lib_rcv() (2013-12-10 22:58:40 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

for you to fetch changes up to a3adadf3018102c24754e0b53a5515c40fbaff4a:

  netfilter: nft_reject: fix endianness in dump function (2013-12-12 09:37:39 +0100)

----------------------------------------------------------------
Eric Leblond (1):
      netfilter: nft_reject: fix endianness in dump function

Patrick McHardy (1):
      netfilter: SYNPROXY target: restrict to INPUT/FORWARD

 net/ipv4/netfilter/ipt_SYNPROXY.c    |    1 +
 net/ipv4/netfilter/nft_reject_ipv4.c |    2 +-
 net/ipv6/netfilter/ip6t_SYNPROXY.c   |    1 +
 3 files changed, 3 insertions(+), 1 deletion(-)


Eric Leblond (1):
  netfilter: nft_reject: fix endianness in dump function

Patrick McHardy (1):
  netfilter: SYNPROXY target: restrict to INPUT/FORWARD

 net/ipv4/netfilter/ipt_SYNPROXY.c    |    1 +
 net/ipv4/netfilter/nft_reject_ipv4.c |    2 +-
 net/ipv6/netfilter/ip6t_SYNPROXY.c   |    1 +
 3 files changed, 3 insertions(+), 1 deletion(-)

-- 
1.7.10.4
