From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [ANNOUNCE] iproute2 4.11
Date: Mon, 1 May 2017 10:32:39 -0700
Message-ID: <20170501103239.48230cfc@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update to iproute2 utility to support new features in Linux 4.11.
Most of the changes are related to recent work for hardware offload
and flow classification in tc.

Also the usual array of small manual and documentaton updates.

Source:
  https://www.kernel.org/pub/linux/utils/net/iproute2/iproute2-4.11.0.tar.gz

Repository:
  git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git

Report problems (or enhancements) to the netdev@vger.kernel.org mailing lis=
t.

---
Alexander Alemayhu (2):
      man: add examples to ip.8
      man: fix man page warnings

Amir Vadai (7):
      tc/pedit: Fix a typo in pedit usage message
      tc/pedit: Extend pedit to specify offset relative to mac/transport he=
aders
      tc/pedit: Introduce 'add' operation
      tc/pedit: p_ip: introduce editing ttl header
      tc/pedit: Support fields bigger than 32 bits
      tc/pedit: p_eth: ETH header editor
      tc/pedit: p_tcp: introduce pedit tcp support

Craig Gallek (1):
      gre6: fix copy/paste bugs in GREv6 attribute manipulation

Daniel Borkmann (2):
      {f,m}_bpf: dump tag over insns
      bpf: test for valid type in bpf_get_work_dir

David Ahern (3):
      ip: Add support for MPLS netconf
      ip route: Add missing space between nexthop and via for mpls multipat=
h routes
      ip vrf: Add command name next to pid

Davide Caratti (1):
      tc: m_csum: add support for SCTP checksum

Hangbin Liu (7):
      iplink: bridge: add support for IFLA_BR_FDB_FLUSH
      iplink: bridge: add support for IFLA_BR_VLAN_STATS_ENABLED
      iplink: bridge: add support for IFLA_BR_MCAST_STATS_ENABLED
      iplink: bridge: add support for IFLA_BR_MCAST_IGMP_VERSION
      iplink: bridge: add support for IFLA_BR_MCAST_MLD_VERSION
      iplink: bridge_slave: add support for IFLA_BRPORT_FLUSH
      man: ip-link.8: Document bridge_slave fdb_flush option

Jamal Hadi Salim (1):
      actions: Add support for user cookies

Jiri Kosina (1):
      iproute2: tc: introduce build dependency on libnetlink

Jiri Pirko (1):
      devlink: use DEVLINK_CMD_ESWITCH_* instead of DEVLINK_CMD_ESWITCH_MOD=
E_*

Michal Kube=C4=8Dek (1):
      routel: fix infinite loop in line parser

Nikolay Aleksandrov (4):
      ipmroute: add support for RTNH_F_UNRESOLVED
      iplink: add support for xstats subcommand
      iplink: bridge: add support for displaying xstats
      iplink: bridge_slave: add support for displaying xstats

Or Gerlitz (1):
      tc/pedit: p_udp: introduce pedit udp support

Paul Blakey (2):
      tc: flower: support matching flags
      tc: flower: Refactor matching flags to be more user friendly

Petr Vorel (1):
      color: use "light" colors for dark background

Phil Sutter (7):
      man: ss.8: Add missing protocols to description of -A
      ip: link: bond: Fix whitespace in help text
      ip: link: macvlan: Add newline to help output
      ip: link: Unify link type help functions a bit
      ip: link: Add missing link type help texts
      man: ip-link: Specify min/max values for bridge slave priority and co=
st
      man: ip-rule.8: Further clarify how to interpret priority value

Robert Shearman (2):
      iplink: add support for afstats subcommand
      man: Fix formatting of vrf parameter of ip-link show command

Roi Dayan (2):
      tc: flower: Fix parsing ip address
      devlink: Add json and pretty options to help and man

Roman Mashak (1):
      tc: print skbedit action when dumping actions.

Sabrina Dubroca (1):
      man: ip-link.8: document bridge options

Simon Horman (9):
      tc: flower: document that *_ip parameters take a PREFIX as an argumen=
t.
      tc: flower: Allow *_mac options to accept a mask
      tc: flower: Update dest UDP port documentation
      tc: flower: Support matching ARP
      tc: flower: use correct type when calling flower_icmp_attr_type
      tc: flower: Update documentation to indicate ARP takes IPv4 prefixes
      tc: flower: provide generic masked u8 parser helper
      tc: flower: provide generic masked u8 print helper
      tc: flower: support masked ICMP code and type match

Stephen Hemminger (24):
      minor kernel header update
      kernel headers update
      add more uapi header files
      include: remove unused header
      update kernel headers from 4.10 net-next
      update kernel headers from net-next
      tcp: header file update
      update headers from bridge tunnel metadata
      tc: add missing sample file
      update headers from net-next
      add missing iplink_xstats.c
      update headers from net-next
      Update headers based on 4.11 merge window
      netlink route attribute cleanup
      xfrm: remove unnecessary casts
      tc: use rta_getattr_u32
      bpf: remove unnecessary cast
      pie: remove always false condition
      update headers from 4.11-rc2
      update headers from 4.11-rc3
      netem: fix out of bounds access in maketable
      iplink: whitespace cleanup
      pedit: fix whitespace
      v4.11.0

Timothy Redaelli (1):
      ip-route: Prevent some other double spaces in output

Vincent Bernat (1):
      vxlan: use preferred address family when neither group or remote is s=
pecified

Yotam Gigi (8):
      tc: Add support for the sample tc action
      tc: man: Add man entry for the tc-sample action
      tc: man: matchall: Update examples to include sample
      tc: bash-completion: Add the _from variant to _tc_one* funcs
      tc: bash-completion: Prepare action autocomplete to support several a=
ctions
      tc: bash-completion: Make the *_KIND variables global
      tc: bash-completion: Add support for filter actions
      tc: bash-completion: Add support for matchall

Zhang Shengju (1):
      iplink: add support for IFLA_CARRIER attribute
