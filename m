From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 00/05: netfilter fixes
Date: Mon,  9 Feb 2009 17:39:27 +0100 (MET)
Message-ID: <20090209163926.13918.96177.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

the following five patches contain netfilter fixes for 2.6.29:

- a patch from Eric Leblond to fix tuple inversion for IPv6 Node Information
  Requests in IPv6 conntrack

- a patch from Eric Leblond to ignore ICMPv6 negotiation messages in IPv6
  conntrack since it can't track multicast communication. This prevents
  those packets from getting marked as INVALID.

- two ctnetlink fixes from Pablo to fix a small inconsistency in conntrack
  creation wrt. NAT sequence number adjustment settings and to fix netlink
  unicast delivery of responses messages.

- a patch from Qu Haoran to fix the SCTP match when matching on the entire
  chunkmap.

Please apply or pull from:

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-2.6.git

Thanks!


 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |   25 ++++++++++++++++++++++-
 net/netfilter/nf_conntrack_netlink.c           |   15 ++++++++++++-
 net/netfilter/xt_sctp.c                        |    2 +-
 3 files changed, 37 insertions(+), 5 deletions(-)

Eric Leblond (2):
      netfilter: fix tuple inversion for Node information request
      netfilter: nf_conntrack_ipv6: don't track ICMPv6 negotiation message

Pablo Neira Ayuso (2):
      netfilter: ctnetlink: allow changing NAT sequence adjustment in creation
      netfilter: ctnetlink: fix echo if not subscribed to any	multicast group

Qu Haoran (1):
      netfilter: xt_sctp: sctp chunk mapping doesn't work
