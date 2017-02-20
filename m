From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [ANNOUNCE] iproute2-4.10
Date: Mon, 20 Feb 2017 09:12:55 -0800
Message-ID: <20170220091255.3557745f@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Release of iproute2 for Linux 4.10

Update to iproute2 utility to support new features in Linux 4.10
This release includes enhanced support for BPF, VRF and Flow based
classifier (flower). The ss utility now can print more information
when using TCP BBR.

Also the usual array of small manual and documentaton updates.

Source:
  https://www.kernel.org/pub/linux/utils/net/iproute2/iproute2-4.10.0.tar.gz

Repository:
  git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git

Report problems (or enhancements) to the netdev@vger.kernel.org mailing lis=
t.

---
Alexander Heinlein (1):
      ip/xfrm: Fix deleteall when having many policies installed

Alexey Kodanev (1):
      fix typo in ip-xfrm man page, rmd610 -> rmd160

Amir Vadai (3):
      libnetlink: Introduce rta_getattr_be*()
      tc/cls_flower: Classify packet in ip tunnels
      tc/act_tunnel: Introduce ip tunnel action

Asbj=C3=B8rn Sloth T=C3=B8nnesen (2):
      testsuite: refactor kernel config search
      testsuite: search for kernel config in /boot

Baruch Siach (1):
      tc: add missing limits.h header

Benjamin LaHaise (1):
      f_flower: don't set TCA_FLOWER_KEY_ETH_TYPE for "protocol all"

Cyrill Gorcunov (2):
      libnetlink: Add test for error code returned from netlink reply
      ss: Add inet raw sockets information gathering via netlink diag inter=
face

Daniel Borkmann (3):
      bpf: make tc's bpf loader generic and move into lib
      bpf: check for owner_prog_type and notify users when differ
      bpf: add initial support for attaching xdp progs

David Ahern (25):
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

David Forster (1):
      ip6tunnel: Align ipv6 tunnel key display with ipv4

David Michael (1):
      tc: make tc linking depend on libtc.a

Eric Dumazet (1):
      ss: print tcpi_rcv_mss and tcpi_advmss

Hadar Hen Zion (4):
      tc/cls_flower: Add dest UDP port to tunnel params
      tc/m_tunnel_key: Add dest UDP port to tunnel key action
      tc/cls_flower: Add to the usage encapsulation dest UDP port
      tc/m_tunnel_key: Add to the usage encapsulation dest UDP port

Hangbin Liu (1):
      man: ip-link.8: Document bridge_slave fdb_flush option

Jamal Hadi Salim (1):
      utils: make hex2mem available to all users

Jiri Benc (1):
      Revert "man pages: add man page for skbmod action"

Julien Fortin (1):
      ip: vfinfo: remove code duplication for IFLA_VF_RSS_QUERY_EN

Leon Romanovsky (1):
      devlink: Call dl_free in early exit case

Lorenzo Colitti (1):
      ip: support UID range routing.

Lucas Bates (1):
      man page: add page for skbmod action

Neal Cardwell (1):
      ss: print new tcp_info fields: delivery_rate and app_limited

Nikolay Aleksandrov (1):
      bridge: fdb: add state filter support

Nogah Frankel (4):
      ifstat: Includes reorder
      ifstat: Add extended statistics to ifstat
      ifstat: Add "sw only" extended statistics to ifstat
      ifstat: Add xstat to ifstat man page

Or Gerlitz (1):
      tc: matchall: Print skip flags when dumping a filter

Petr Vorel (1):
      ip: fix igmp parsing when iface is long

Phil Sutter (24):
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

Ralf Baechle (1):
      ip: HSR: Fix cut and paste error

Roi Dayan (7):
      devlink: Add usage help for eswitch subcommand
      devlink: Add option to set and show eswitch inline mode
      tc: flower: Fix typo and style in flower man page
      tc: tunnel_key: Add tc-tunnel_key man page to Makefile
      tc: flower: Fix flower output for src and dst ports
      tc: flower: Add missing err check when parsing flower options
      tc: flower: Fix incorrect error msg about eth type

Roman Mashak (4):
      tc: pass correct conversion specifier to print 'unsigned int' action =
index.
      tc: fixed man page fonts for keywords and variable values
      tc: updated man page to reflect filter-id use in filter GET command.
      tc: distinguish Add/Replace action operations.

Shmulik Ladkani (1):
      tc: m_mirred: Add support for ingress redirect/mirror

Simon Horman (10):
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
      tc: ife: correct spelling of prio in example

Stephen Hemminger (20):
      update kernel headers
      tc: flower checkpatch cleanups
      lwtunnel: style cleanup
      libnetlink: break up dump function
      utils: cleanup style
      ipvrf: cleanup style issues
      configure: fix elftest when warnings enabled
      Revert "tc: flower: document that *_ip parameters take a PREFIX as an=
 argument."
      Revert "tc: flower: Allow *_mac options to accept a mask"
      whitespace cleanup
      utils: hex2mem get rid of unnecessary goto
      v4.10.0

Thomas Graf (2):
      bpf: Fix number of retries when growing log buffer
      lwt: BPF support for LWT

Yotam Gigi (1):
      tc: man: matchall: Fix example indentation

Yuchung Cheng (1):
      ss: print new tcp_info fields: busy, rwnd-limited, sndbuf-limited tim=
es
