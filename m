From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [ANNOUNCE] iproute2 4.12.0
Date: Wed, 5 Jul 2017 09:14:00 -0700
Message-ID: <20170705091400.4f94325a@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Release of iproute2 for Linux 4.12

Usual update to iproute2 utility to support new features in Linux 4.12.
More changes to flower support and lots of littele TC enhancements.
Also the usual array of small manual and documentaton updates.

Source:
  https://www.kernel.org/pub/linux/utils/net/iproute2/iproute2-4.12.0.tar.gz

Repository:
  git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git

Report problems (or enhancements) to the netdev@vger.kernel.org mailing lis=
t.

---
Alexander Alemayhu (3):
      man: add examples to ip.8
      man: fix man page warnings
      tc: bpf: add ppc64 and sparc64 to list of archs with eBPF support

Alexander Heinlein (1):
      ip/xfrm: Fix deleteall when having many policies installed

Alexey Kodanev (1):
      fix typo in ip-xfrm man page, rmd610 -> rmd160

Amir Vadai (14):
      libnetlink: Introduce rta_getattr_be*()
      tc/cls_flower: Classify packet in ip tunnels
      tc/act_tunnel: Introduce ip tunnel action
      tc/pedit: Fix a typo in pedit usage message
      tc/pedit: Extend pedit to specify offset relative to mac/transport he=
aders
      tc/pedit: Introduce 'add' operation
      tc/pedit: p_ip: introduce editing ttl header
      tc/pedit: Support fields bigger than 32 bits
      tc/pedit: p_eth: ETH header editor
      tc/pedit: p_tcp: introduce pedit tcp support
      pedit: Fix a typo in warning
      pedit: Do not allow using retain for too big fields
      pedit: Check for extended capability in protocol parser
      pedit: Introduce ipv6 support

Arkadi Sharshevsky (2):
      devlink: Change netlink attribute validation
      devlink: Add support for pipeline debug (dpipe)

Asbj=C3=B8rn Sloth T=C3=B8nnesen (2):
      testsuite: refactor kernel config search
      testsuite: search for kernel config in /boot

Baruch Siach (2):
      tc: add missing limits.h header
      ip: include libc headers first

Benjamin LaHaise (1):
      f_flower: don't set TCA_FLOWER_KEY_ETH_TYPE for "protocol all"

Boris Pismenny (1):
      ip xfrm: Add xfrm state crypto offload

Craig Gallek (2):
      gre6: fix copy/paste bugs in GREv6 attribute manipulation
      iplink: Expose IFLA_*_FWMARK attributes for supported link types

Cyrill Gorcunov (2):
      libnetlink: Add test for error code returned from netlink reply
      ss: Add inet raw sockets information gathering via netlink diag inter=
face

Daniel Borkmann (9):
      bpf: make tc's bpf loader generic and move into lib
      bpf: check for owner_prog_type and notify users when differ
      bpf: add initial support for attaching xdp progs
      {f,m}_bpf: dump tag over insns
      bpf: test for valid type in bpf_get_work_dir
      bpf: add support for generic xdp
      bpf: update printing of generic xdp mode
      bpf: dump error to the user when retrieving pinned prog fails
      bpf: indicate lderr when bpf_apply_relo_data fails

David Ahern (39):
      Makefile: really suppress printing of directories
      lib bpf: Add support for BPF_PROG_ATTACH and BPF_PROG_DETACH
      bpf: export bpf_prog_load
      bpf: Add BPF_ macros
      move cmd_exec to lib utils
      Add filesystem APIs to lib
      change name_is_vrf to return index
      libnetlink: Add variant of rtnl_talk that does not display RTNETLINK =
answers error
      Introduce ip vrf command
      Fix compile warning in get_addr_1
      ip vrf: Move kernel config hint to prog_load failure
      ip vrf: Refactor ipvrf_identify
      ip vrf: Fix reset to default VRF
      ip netns: Reset vrf to default VRF on namespace switch
      ip vrf: Fix run-on error message on mkdir failure
      ip vrf: Improve cgroup2 error messages
      ip vrf: Improve bpf error messages
      Add support for rt_protos.d
      rttable: Fix invalid range checking when table id is converted to u32
      ip route: error out on multiple via without nexthop keyword
      ip route: Make name of protocol 0 consistent
      ip vrf: Handle vrf in a cgroup hierarchy
      ip netns: refactor netns_identify
      ip vrf: Handle VRF nesting in namespace
      ip vrf: Detect invalid vrf name in pids command
      ip: Add support for MPLS netconf
      ip route: Add missing space between nexthop and via for mpls multipat=
h routes
      netlink: Add flag to suppress print of nlmsg error
      ip netconf: Show all address families by default in dumps
      ip netconf: show all families on dev request
      ip vrf: Add command name next to pid
      ip vrf: Add command name next to pid
      ip: mpls: fix printing of mpls labels
      ip: add support for more MPLS labels
      netlink: Change rtnl_dump_done to always show error
      ip address: Export ip_linkaddr_list
      ip address: Move filter struct to ip_common.h
      ip address: Change print_linkinfo_brief to take filter as an input
      ip vrf: Add show command

David Forster (1):
      ip6tunnel: Align ipv6 tunnel key display with ipv4

David Lebrun (4):
      ip: add ip sr command to control SR-IPv6 internal structures
      iproute: add support for SR-IPv6 lwtunnel encapsulation
      man: add documentation for IPv6 SR commands
      iproute: fix compilation issue with older glibc

David Michael (1):
      tc: make tc linking depend on libtc.a

Davide Caratti (1):
      tc: m_csum: add support for SCTP checksum

Donald Sharp (1):
      ip: mroute: Add table output to show command

Eli Cohen (1):
      iplink: Update usage in help message

Eric Dumazet (1):
      ss: print tcpi_rcv_mss and tcpi_advmss

Girish Moodalbail (1):
      vxlan: Add support for modifying vxlan device attributes

Hadar Hen Zion (4):
      tc/cls_flower: Add dest UDP port to tunnel params
      tc/m_tunnel_key: Add dest UDP port to tunnel key action
      tc/cls_flower: Add to the usage encapsulation dest UDP port
      tc/m_tunnel_key: Add to the usage encapsulation dest UDP port

Hangbin Liu (9):
      iplink: bridge: add support for IFLA_BR_FDB_FLUSH
      iplink: bridge: add support for IFLA_BR_VLAN_STATS_ENABLED
      iplink: bridge: add support for IFLA_BR_MCAST_STATS_ENABLED
      iplink: bridge: add support for IFLA_BR_MCAST_IGMP_VERSION
      iplink: bridge: add support for IFLA_BR_MCAST_MLD_VERSION
      iplink: bridge_slave: add support for IFLA_BRPORT_FLUSH
      man: ip-link.8: Document bridge_slave fdb_flush option
      man: ip-link.8: Document bridge_slave fdb_flush option
      ip neigh: allow flush FAILED neighbour entry

Jakub Sitnicki (1):
      iproute: Remove useless check for nexthop keyword when setting RTA_OIF

Jamal Hadi Salim (2):
      utils: make hex2mem available to all users
      actions: Add support for user cookies

Jiri Benc (1):
      Revert "man pages: add man page for skbmod action"

Jiri Kosina (2):
      iproute2: tc: introduce build dependency on libnetlink
      iproute2: add support for invisible qdisc dumping

Jiri Pirko (1):
      devlink: use DEVLINK_CMD_ESWITCH_* instead of DEVLINK_CMD_ESWITCH_MOD=
E_*

Julien Fortin (1):
      ip: vfinfo: remove code duplication for IFLA_VF_RSS_QUERY_EN

Khem Raj (1):
      tc: include stdint.h explicitly for UINT16_MAX

Krister Johansen (3):
      iptunnel: document mode parameter for sit tunnels
      iptunnel: add support for mpls/ip to sit tunnels
      iptunnel: add support for mpls/ip to ipip tunnels

Leon Romanovsky (1):
      devlink: Call dl_free in early exit case

Lorenzo Colitti (1):
      ip: support UID range routing.

Lucas Bates (2):
      man page: add page for skbmod action
      Add new man page for tc actions.

Lukas Braun (1):
      man: ip-route.8: Mention that lower metric means higher priority

Michal Kube=C4=8Dek (1):
      routel: fix infinite loop in line parser

Neal Cardwell (1):
      ss: print new tcp_info fields: delivery_rate and app_limited

Nicolas Dichtel (1):
      link_gre6: really support encaplimit option

Nikolay Aleksandrov (5):
      bridge: fdb: add state filter support
      ipmroute: add support for RTNH_F_UNRESOLVED
      iplink: add support for xstats subcommand
      iplink: bridge: add support for displaying xstats
      iplink: bridge_slave: add support for displaying xstats

Nogah Frankel (4):
      ifstat: Includes reorder
      ifstat: Add extended statistics to ifstat
      ifstat: Add "sw only" extended statistics to ifstat
      ifstat: Add xstat to ifstat man page

Oliver Hartkopp (1):
      ip: link add vxcan support

Or Gerlitz (3):
      tc: matchall: Print skip flags when dumping a filter
      tc/pedit: p_udp: introduce pedit udp support
      tc: Reflect HW offload status

Paul Blakey (2):
      tc: flower: support matching flags
      tc: flower: Refactor matching flags to be more user friendly

Petr Vorel (2):
      ip: fix igmp parsing when iface is long
      color: use "light" colors for dark background

Phil Sutter (34):
      ss: Mark fall through in arg parsing switch()
      ss: Drop empty lines in UDP output
      ss: Add missing tab when printing UNIX details
      ss: Use sockstat->type in all socket types
      ss: introduce proc_ctx_print()
      ss: Drop list traversal from unix_stats_print()
      ss: Eliminate unix_use_proc()
      ss: Turn generic_proc_open() wrappers into macros
      ss: Make tmr_name local to tcp_timer_print()
      ss: Make user_ent_hash_build_init local to user_ent_hash_build()
      ss: Make some variables function-local
      ss: Make slabstat_ids local to get_slabstat()
      ss: Get rid of useless goto in handle_follow_request()
      ss: Get rid of single-fielded struct snmpstat
      ss: Make unix_state_map local to unix_show()
      ss: Make sstate_name local to sock_state_print()
      ss: Make sstate_namel local to scan_state()
      ss: unix_show: No need to initialize members of calloc'ed structs
      tc: m_xt: Fix segfault with iptables-1.6.0
      tc: m_xt: Drop needless parentheses from #if checks
      man: tc-csum.8: Fix example
      man: ip-route.8: Fix 'expires' indenting
      testsuite: Generate nlmsg blob at runtime
      testsuite: Search kernel config in modules dir also
      man: ss.8: Add missing protocols to description of -A
      ip: link: bond: Fix whitespace in help text
      ip: link: macvlan: Add newline to help output
      ip: link: Unify link type help functions a bit
      ip: link: Add missing link type help texts
      man: ip-link: Specify min/max values for bridge slave priority and co=
st
      man: ip-rule.8: Further clarify how to interpret priority value
      man: ip.8: Document -brief flag
      tc: m_xt: Prevent a segfault in libipt
      man: Collect names of man pages automatically

Ralf Baechle (1):
      ip: HSR: Fix cut and paste error

Remigiusz Ko=C5=82=C5=82=C4=85taj (1):
      ip: add handling for new CAN netlink interface

Robert Shearman (4):
      iplink: add support for afstats subcommand
      man: Fix formatting of vrf parameter of ip-link show command
      iproute: Add support for ttl-propagation attribute
      iproute: Add support for MPLS LWT ttl attribute

Roi Dayan (10):
      devlink: Add usage help for eswitch subcommand
      devlink: Add option to set and show eswitch inline mode
      tc: flower: Fix typo and style in flower man page
      tc: tunnel_key: Add tc-tunnel_key man page to Makefile
      tc: flower: Fix flower output for src and dst ports
      tc: flower: Add missing err check when parsing flower options
      tc: flower: Fix incorrect error msg about eth type
      tc: flower: Fix parsing ip address
      devlink: Add json and pretty options to help and man
      devlink: Add option to set and show eswitch encapsulation support

Roman Mashak (9):
      tc: pass correct conversion specifier to print 'unsigned int' action =
index.
      tc: fixed man page fonts for keywords and variable values
      tc: updated man page to reflect filter-id use in filter GET command.
      tc: distinguish Add/Replace action operations.
      tc: print skbedit action when dumping actions.
      tc: fix Makefile to build skbmod
      tc: fixed typo in usage text.
      tc: updated tc-u32 man page to reflect skip_sw and skip_hw parameters.
      tc: updated ife man page.

Sabrina Dubroca (1):
      man: ip-link.8: document bridge options

Shmulik Ladkani (1):
      tc: m_mirred: Add support for ingress redirect/mirror

Simon Horman (19):
      tc: flower: Support matching on SCTP ports
      tc: flower: remove references to eth_type in manpage
      tc: flower: document SCTP ip_proto
      tc: flower: correct name of ip_proto parameter to flower_parse_port()
      tc: flower: make use of flower_port_attr_type() safe and silent
      tc: flower: introduce enum flower_endpoint
      tc: flower: support matching on ICMP type and code
      tc: flower: document that *_ip parameters take a PREFIX as an argumen=
t.
      tc: flower: Allow *_mac options to accept a mask
      tc: flower: document that *_ip parameters take a PREFIX as an argumen=
t.
      tc: flower: Allow *_mac options to accept a mask
      tc: flower: Update dest UDP port documentation
      tc: ife: correct spelling of prio in example
      tc: flower: Support matching ARP
      tc: flower: use correct type when calling flower_icmp_attr_type
      tc: flower: Update documentation to indicate ARP takes IPv4 prefixes
      tc: flower: provide generic masked u8 parser helper
      tc: flower: provide generic masked u8 print helper
      tc: flower: support masked ICMP code and type match

Stephen Hemminger (58):
      update kernel headers to 4.9-net-next
      update net-next headers
      tc: flower checkpatch cleanups
      Update kernel headers for XDP and tcp_info
      update kernel headers from net-next
      update kernel headers from net-next
      update to net-next headers (pre 4.10 rc)
      lwtunnel: style cleanup
      libnetlink: break up dump function
      utils: cleanup style
      ipvrf: cleanup style issues
      configure: fix elftest when warnings enabled
      update kernel headers
      Revert "tc: flower: document that *_ip parameters take a PREFIX as an=
 argument."
      Revert "tc: flower: Allow *_mac options to accept a mask"
      minor kernel header update
      whitespace cleanup
      kernel headers update
      add more uapi header files
      include: remove unused header
      update kernel headers (from 4.10-rc4)
      update kernel headers from 4.10 net-next
      update kernel headers from net-next
      tcp: header file update
      update headers from bridge tunnel metadata
      tc: add missing sample file
      update headers from net-next
      update headers from 4.10-rc8
      utils: hex2mem get rid of unnecessary goto
      v4.10.0
      add missing iplink_xstats.c
      update headers from net-next
      Update headers based on 4.11 merge window
      netlink route attribute cleanup
      xfrm: remove unnecessary casts
      tc: use rta_getattr_u32
      bpf: remove unnecessary cast
      pie: remove always false condition
      update headers from 4.11-rc2
      update kernel headers from net-next
      update headers from net-next
      update headers from 4.11-rc3
      update headers from net-next (post 4.11-rc3)
      update kernel headers from net-next
      netem: fix out of bounds access in maketable
      Update kernel headers from 4.11 net-next
      add seg6.h kernel headers
      update kernel headers from net-next
      remove unused header file sysctl.h
      iplink: whitespace cleanup
      pedit: fix whitespace
      update headers to 4.11 net-next
      v4.11.0
      update kernel headers during 4.12 merge window
      update headers from 4.12-rc2
      include: remove no longer used iptables_common.h
      xfrm: get #define's from linux includes
      v4.12.0

Thomas Graf (2):
      bpf: Fix number of retries when growing log buffer
      lwt: BPF support for LWT

Timothy Redaelli (1):
      ip-route: Prevent some other double spaces in output

Vincent Bernat (1):
      vxlan: use preferred address family when neither group or remote is s=
pecified

Yotam Gigi (9):
      tc: man: matchall: Fix example indentation
      tc: Add support for the sample tc action
      tc: man: Add man entry for the tc-sample action
      tc: man: matchall: Update examples to include sample
      tc: bash-completion: Add the _from variant to _tc_one* funcs
      tc: bash-completion: Prepare action autocomplete to support several a=
ctions
      tc: bash-completion: Make the *_KIND variables global
      tc: bash-completion: Add support for filter actions
      tc: bash-completion: Add support for matchall

Yuchung Cheng (1):
      ss: print new tcp_info fields: busy, rwnd-limited, sndbuf-limited tim=
es

Zhang Shengju (1):
      iplink: add support for IFLA_CARRIER attribute
