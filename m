From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Mon, 20 Oct 2008 03:45:17 -0700 (PDT)
Message-ID: <20081020.034517.125315138.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752710AbYJTKvb@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


=46ixes all over, highlights:

1) Netfilter build fix for the problem reported by Ben H. and Ingo.

2) sch_teql OOPS fix, will be sent to -stable as well, from Jarek Popla=
wski

3) Fallout from the TPROXY changes in TCP/ipv6 and DCCP, fixed by
   KOVACS Krisztian and Gerrit Renker.

4) Net device name change rollback returns the wrong error code, from
   Stephen Hemminger.

Please pull thanks a lot!

The following changes since commit 95a5afca4a8d2e1cb77e1d4bc6ff9f718dc3=
2f7a:
  Johannes Berg (1):
        net: Remove CONFIG_KMOD from net/ (towards removing CONFIG_KMOD=
 entirely)

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Alexey Dobriyan (2):
      netfilter: xt_iprange: fix range inversion match
      netfilter: xt_recent: use proc_create_data()

Gerrit Renker (1):
      dccp: Port redirection support for DCCP

Ilpo J=E4rvinen (1):
      netfilter: snmp nat leaks memory in case of failure

Jan Engelhardt (1):
      netfilter: replace old NF_ARP calls with NFPROTO_ARP

Jarek Poplawski (1):
      pkt_sched: sch_generic: Fix oops in sch_teql

Julius Volz (1):
      ipvs: Update CONFIG_IP_VS_IPV6 description and help text

KOVACS Krisztian (1):
      tcp: Fix IPv6 fallout from 'Port redirection support for TCP'

Pablo Neira Ayuso (1):
      netfilter: fix compilation error with NAT=3Dn

Patrick McHardy (2):
      netfilter: ctnetlink: remove obsolete NAT dependency from Kconfig
      netfilter: netns: use NFPROTO_NUMPROTO instead of NUMPROTO for ta=
bles array

Stephen Hemminger (1):
      netdev: change name dropping error codes

 include/net/netns/x_tables.h           |    4 ++--
 net/bridge/br_netfilter.c              |    2 +-
 net/core/dev.c                         |    6 +++---
 net/dccp/ipv6.c                        |    4 ++--
 net/dccp/minisocks.c                   |    1 +
 net/dccp/output.c                      |    2 +-
 net/ipv4/arp.c                         |    4 ++--
 net/ipv4/netfilter/nf_nat_snmp_basic.c |    1 +
 net/ipv6/syncookies.c                  |    1 +
 net/ipv6/tcp_ipv6.c                    |    6 +++---
 net/netfilter/Kconfig                  |    1 -
 net/netfilter/ipvs/Kconfig             |    4 +++-
 net/netfilter/nf_conntrack_netlink.c   |    2 ++
 net/netfilter/xt_NFQUEUE.c             |    2 +-
 net/netfilter/xt_iprange.c             |    8 ++++----
 net/netfilter/xt_recent.c              |   10 ++++------
 net/sched/sch_generic.c                |    2 ++
 17 files changed, 33 insertions(+), 27 deletions(-)
