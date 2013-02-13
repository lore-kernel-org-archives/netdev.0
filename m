From: pablo@netfilter.org
Subject: [PATCH 0/3] netfilter fixes for 3.7-rc8
Date: Wed, 13 Feb 2013 21:38:30 +0100
Message-ID: <1360787913-10335-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Pablo Neira Ayuso <pablo@netfilter.org>

Hi David,

The following patchset contains three Netfilter fixes, they are:

* Fix conntrack helper re-assignment after NAT mangling if only if
  the same helper is attached to the conntrack again, from Florian
  Westphal.

* Don't allow the creation of conntrack entries via ctnetlink if the
  original and reply tuples are missing, from Florian Westphal.

* Fix broken sysctl interface in nf_ct_reasm while adding netns support
  to it, from Michal Kubecek.

Again, these are coming very late but they seem small and non-intrusive=
 to me.
If case your verdict is positive, you can pull this changes from:

git://1984.lsi.us.es/nf master

Thanks!

=46lorian Westphal (2):
  netfilter: ctnetlink: don't permit ct creation with random tuple
  netfilter: nf_ct_helper: don't discard helper if it is actually the s=
ame

Michal Kube=C4=8Dek (1):
  netfilter: nf_ct_reasm: fix per-netns sysctl initialization

 net/ipv6/netfilter/nf_conntrack_reasm.c |    6 +++---
 net/netfilter/nf_conntrack_helper.c     |    4 +++-
 net/netfilter/nf_conntrack_netlink.c    |    3 +++
 3 files changed, 9 insertions(+), 4 deletions(-)

--=20
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
