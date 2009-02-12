From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 00/02: netfilter -stable fixes
Date: Thu, 12 Feb 2009 08:07:35 +0100 (MET)
Message-ID: <20090212070732.4876.43180.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, davem@davemloft.net
To: stable@kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches against the last -stable version fix two netfilter bugs:

- IPv6 conntrack incorrectly created inverted tuples for Node
  Information Requests

- the sctp match doesn't work at all when matching on the entire
  chunkmap

Please apply, thanks.


 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |    4 ++--
 net/netfilter/xt_sctp.c                        |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

Eric Leblond (1):
      netfilter: fix tuple inversion for Node information request

Qu Haoran (1):
      netfilter: xt_sctp: sctp chunk mapping doesn't work
