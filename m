From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [ANNOUNCE] iproute2 4.5
Date: Mon, 14 Mar 2016 16:10:06 -0700
Message-ID: <20160314161006.139f896d@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Update to iproute2 utility to support new features in Linux 4.5.
The usual array small documentation changes and bug fixes.
Areas of large changes were BPF and more integration of management
of bridges.

Source:
  http://www.kernel.org/pub/linux/utils/net/iproute2/iproute2-4.5.0.tar=
=2Egz

Repository:
  git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git

Report problems (or enhancements) to the netdev@vger.kernel.org mailing=
 list.

Net-next changes will be merged in next week.

---
Bj=C3=B8rn Mork (3):
      iplink: support setting addrgenmode stable_secret
      iplink: support show and set of "addrgenmode random"
      man: iplink: document new addrgenmodes

Daniel Borkmann (17):
      {f,m}_bpf: allow for sharing maps
      {f,m}_bpf: make tail calls working
      {f, m}_bpf: check map attributes when fetching as pinned
      {f, m}_bpf: allow for user-defined object pinnings
      {f,m}_bpf: allow updates on program arrays
      {f,m}_bpf: add more example code
      examples, bpf: further improve examples
      bpf: minor fix in api and bpf_dump_error() usage
      tc, ingress: clean up ingress handling a bit
      tc, clsact: add clsact frontend
      tc, bpf: check section names and type everywhere
      tc, bpf: more header checks on loading elf
      tc, bpf: make sure relo is in relation with map section
      tc, bpf, examples: further bpf_api improvements
      tc, bpf: improve verifier logging
      tc, bpf: give some more hints wrt false relos
      tc, bpf: use bind/type macros from gelf

Dmitrii Shcherbakov (2):
      htb: remove printing of a deprecated overhead value
      htb: rename b4 buffer to b3 to make its name more consistent

Gustavo Zacarias (1):
      iproute2: fix building with musl

Hangbin Liu (3):
      route: allow routes to be configured with expire values
      iproute2: ip-route.8.in: Add missing '[' before 'pref'
      iproute2: ip-route.8.in: Add expires option for ip route

Hiroshi Shimamoto (1):
      iplink: Support VF Trust

John W. Linville (1):
      geneve: add support for IPv6 link partners

Lorenzo Colitti (2):
      libnetlink: don't print NETLINK_SOCK_DIAG errors in rtnl_talk
      ss: support closing inet sockets via SOCK_DESTROY.

Nicolas Cavallari (1):
      netns: Fix an off-by-one strcpy() in netns_map_add().

Nicolas Dichtel (1):
      tc: fix compilation with old gcc (< 4.6) (bis)

Nikolay Aleksandrov (28):
      iplink: bridge: export bridge_id and designated_root
      iplink: bridge: export root_(port|path_cost), topology_change and=
 change_detected
      iplink: bridge: export read-only timers
      iplink: bridge: add support for IFLA_BR_GROUP_FWD_MASK
      iplink: bridge: add support for IFLA_BR_GROUP_ADDR
      iplink: bridge: add support for IFLA_BR_VLAN_DEFAULT_PVID
      iplink: bridge: add support for IFLA_BR_MCAST_ROUTER
      iplink: bridge: add support for IFLA_BR_MCAST_SNOOPING
      iplink: bridge: add support for IFLA_BR_MCAST_QUERY_USE_IFADDR
      iplink: bridge: add support for IFLA_BR_MCAST_QUERIER
      iplink: bridge: add support for IFLA_BR_MCAST_HASH_ELASTICITY
      iplink: bridge: add support for IFLA_BR_MCAST_HASH_MAX
      iplink: bridge: add support for IFLA_BR_MCAST_LAST_MEMBER_CNT
      iplink: bridge: add support for IFLA_BR_MCAST_STARTUP_QUERY_CNT
      iplink: bridge: add support for IFLA_BR_MCAST_LAST_MEMBER_INTVL
      iplink: bridge: add support for IFLA_BR_MCAST_MEMBERSHIP_INTVL
      iplink: bridge: add support for IFLA_BR_MCAST_QUERIER_INTVL
      iplink: bridge: add support for IFLA_BR_MCAST_QUERY_INTVL
      iplink: bridge: add support for IFLA_BR_MCAST_QUERY_RESPONSE_INTV=
L
      iplink: bridge: add support for IFLA_BR_MCAST_STARTUP_QUERY_INTVL
      iplink: bridge: add support for netfilter call attributes
      iplink: bond_slave: fix ad_actor/partner_oper_port_state output
      iplink: bridge_slave: export read-only values
      iplink: bridge_slave: add support for IFLA_BRPORT_PROXYARP
      iplink: bridge_slave: add support for IFLA_BRPORT_PROXYARP_WIFI
      iplink: bridge_slave: add support for IFLA_BRPORT_MULTICAST_ROUTE=
R
      iplink: bridge_slave: add support for IFLA_BRPORT_FAST_LEAVE
      iplink: bridge: remove unnecessary returns

Paolo Abeni (1):
      geneve: add support for lwt tunnel creation and dst port selectio=
n

Phil Sutter (46):
      iprule: Align help text with man page synopsis
      ipl2tp: Print help even on systems without l2tp support
      ip: align help text with manpage
      ipaddrlabel: Improve help text precision
      iplink: fix help text syntax
      ipneigh: add missing proxy keyword to help text
      ipntable: Fix typo in help text
      iproute: TYPE keyword is not optional, fix help text accordingly
      iprule: add missing nat keyword to help text
      man: ip-address.8: Minor syntax fixes
      man: ip-link.8: minor font fix
      man: ip-link.8: Fix and improve synopsis
      man: ip-neighbour: Fix for missing NUD_STATE description
      man: ip-netns.8: Clarify synopsis a bit
      man: ip-ntable.8: Review synopsis section
      man: ip-rule.8: Review synopsis section
      man: ip-token.8: Review synopsis section
      man: ip-tunnel.8: Document missing 6rd action
      man: ip-xfrm.8: Document missing parameters
      man: ip.8: Add missing flags and token subcommand description
      man: ip-l2tp.8: Fix BNF syntax
      man: ip-*.8: drop any reference to generic ip options
      man: Add a man page for the connmark action
      man: Add a man page for the csum action.
      man: Add a man page for the mirred action
      man: Add a man page for the nat action
      man: Add a man page for the pedit action
      man: Add a man page for the police action
      man: Add a man page for the simple action
      man: Add a man page for the skbedit action
      man: Add a man page for the vlan action
      man: Add a man page for the xt action
      man: ship action man pages
      man: tc-u32: Minor syntax fix
      man: ip-link: Beef up VXLAN csum options a bit
      tc: pedit: document branch control in help output
      man: ip-route: Make synopsis consistent with description
      doc, man: ip-rule: Remove incorrect statement about rule 0
      man: ip-neighbour.8: Document all known nud states
      ipneigh: List all nud states in help output
      doc: Add my article about tc, filters and actions
      ifstat, nstat: fix daemon mode
      libnetlink: Double the dump buffer size
      tc: pedit: Fix layered op parsing
      tc: pedit: Fix parse_cmd()
      tc: pedit: Fix retain value for ihl adjustments

Richard Alpe (1):
      tipc: add peer remove functionality

Roopa Prabhu (4):
      ipmonitor: match user option 'all' before 'all-nsid'
      bridge: support for static fdb entries
      ip route: add mpls multipath support
      bridge: add support for dynamic fdb entries

Stephen Hemminger (12):
      qfq: fix parse_opt dead code
      include: update kernel headers
      genl: make string const
      monitor: fix file handle leak
      lnstat: fix error handling
      add coverity model file
      Update to current iptables headers
      update most kernel headers
      Revert "tc: fix compilation with old gcc (< 4.6)"
      update headers (post 4.4 merge window)
      Revert "tipc: add peer remove functionality"
      v4.5.0

Thomas Faivre (2):
      vxlan: fix help and man text
      ip-link: fix man page warnings

Zhang Shengju (1):
      ip-link: remove warning message
