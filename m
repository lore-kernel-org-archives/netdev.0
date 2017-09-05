From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [ANNOUNCE] Iproute2 for Linux 4.13
Date: Tue, 5 Sep 2017 09:49:40 -0700
Message-ID: <20170905094940.20421c65@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:33348 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752129AbdIEQts (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2017 12:49:48 -0400
Received: by mail-pg0-f53.google.com with SMTP id t3so10502238pgt.0
        for <netdev@vger.kernel.org>; Tue, 05 Sep 2017 09:49:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Update to iproute2 utility to support new features in Linux 4.13.
This is a larger than usual release because of lots of updates for BPF
and the new RDMA utility. Lots of cleanups and Coverity reported
potential issues as well.

Source:
  https://www.kernel.org/pub/linux/utils/net/iproute2/iproute2-4.13.0.tar.gz

Repository:
  git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git

Report problems (or enhancements) to the netdev@vger.kernel.org mailing lis=
t.

---
Alexander Alemayhu (1):
      examples/bpf: update list of examples

Andreas Henriksson (1):
      ss: fix help/man TCP-STATE description for listening

Arkadi Sharshevsky (1):
      bridge: Distinguish between externally learned vs offloaded FDBs

Casey Callendrello (1):
      netns: make /var/run/netns bind-mount recursive

Daniel Borkmann (8):
      bpf: remove obsolete samples
      bpf: support loading map in map from obj
      bpf: dump id/jited info for cls/act programs
      bpf: improve error reporting around tail calls
      bpf: fix mnt path when from env
      bpf: unbreak libelf linkage for bpf obj loader
      bpf: minor cleanups for bpf_trace_pipe
      bpf: consolidate dumps to use bpf_dump_prog_info

David Ahern (2):
      lib: Dump ext-ack string by default
      libnetlink: Fix extack attribute parsing

Girish Moodalbail (1):
      geneve: support for modifying geneve device

Hangbin Liu (1):
      utils: return default family when rtm_family is not RTNL_FAMILY_IPMR/=
IP6MR

Jakub Kicinski (3):
      bpf: print xdp offloaded mode
      bpf: add xdpdrv for requesting XDP driver mode
      bpf: allow requesting XDP HW offload

Jiri Benc (2):
      tc: m_tunnel_key: reformat the usage text
      tc: m_tunnel_key: add csum/nocsum option

Jiri Pirko (7):
      tc_filter: add support for chain index
      tc: actions: add helpers to parse and print control actions
      tc/actions: introduce support for goto chain action
      tc: flower: add support for tcp flags
      tc: gact: fix control action parsing
      tc: add support for TRAP action
      tc: don't print error message on miss when parsing action with default

Leon Romanovsky (8):
      utils: Move BIT macro to common header
      rdma: Add basic infrastructure for RDMA tool
      rdma: Add dev object
      rdma: Add link object
      rdma: Add json and pretty outputs
      rdma: Implement json output for dev object
      rdma: Add json output to link object
      rdma: Add initial manual for the tool

Martin KaFai Lau (1):
      bpf: Add support for IFLA_XDP_PROG_ID

Matteo Croce (3):
      tc: fix typo in manpage
      netns: avoid directory traversal
      netns: more input validation

Michal Kubecek (2):
      iplink: check for message truncation in iplink_get()
      iplink: double the buffer size also in iplink_get()

Or Gerlitz (1):
      tc: flower: add support for matching on ip tos and ttl

Phil Sutter (58):
      bpf: Make bytecode-file reading a little more robust
      Really fix get_addr() and get_prefix() error messages
      tc-simple: Fix documentation
      examples: Some shell fixes to cbq.init
      ifcfg: Quote left-hand side of [ ] expression
      tipc/node: Fix socket fd check in cmd_node_get_addr()
      iproute_lwtunnel: Argument to strerror must be positive
      iproute_lwtunnel: csum_mode value checking was ineffective
      ss: Don't leak fd in tcp_show_netlink_file()
      tc/em_ipset: Don't leak sockfd on error path
      ipvrf: Fix error path of vrf_switch()
      ifstat: Fix memleak in error case
      ifstat: Fix memleak in dump_kern_db() for json output
      ss: Fix potential memleak in unix_stats_print()
      tipc/bearer: Fix resource leak in error path
      devlink: No need for this self-assignment
      ipntable: No need to check and assign to parms_rta
      iproute: Fix for missing 'Oifs:' display
      lib/rt_names: Drop dead code in rtnl_rttable_n2a()
      ss: Skip useless check in parse_hostcond()
      ss: Drop useless assignment
      tc/m_gact: Drop dead code
      ipaddress: Avoid accessing uninitialized variable lcl
      iplink_can: Prevent overstepping array bounds
      ipmaddr: Avoid accessing uninitialized data
      ss: Use C99 initializer in netlink_show_one()
      netem/maketable: Check return value of fstat()
      tc/q_multiq: Don't pass garbage in TCA_OPTIONS
      iproute: Check mark value input
      iplink_vrf: Complain if main table is not found
      devlink: Check return code of strslashrsplit()
      lib/bpf: Don't leak fp in bpf_find_mntpt()
      ifstat, nstat: Check fdopen() return value
      tc/q_netem: Don't dereference possibly NULL pointer
      tc/tc_filter: Make sure filter name is not empty
      tipc/bearer: Prevent NULL pointer dereference
      ipntable: Avoid memory allocation for filter.name
      lib/fs: Fix format string in find_fs_mount()
      lib/inet_proto: Review inet_proto_{a2n,n2a}()
      lnstat_util: Simplify alloc_and_open() a bit
      tc/m_xt: Fix for potential string buffer overflows
      lib/ll_map: Choose size of new cache items at run-time
      ss: Make struct tcpstat fields 'timer' and 'timeout' unsigned
      ss: Make sure scanned index value to unix_state_map is sane
      netem/maketable: Check return value of fscanf()
      lib/bpf: Check return value of write()
      lib/fs: Fix and simplify make_path()
      lib/libnetlink: Don't pass NULL parameter to memcpy()
      ss: Fix for added diag support check
      link_gre6: Fix for changing tclass/flowlabel
      link_gre6: Print the tunnel's tclass setting
      utils: Implement strlcpy() and strlcat()
      Convert the obvious cases to strlcpy()
      Convert harmful calls to strncpy() to strlcpy()
      ipxfrm: Replace STRBUF_CAT macro with strlcat()
      tc_util: No need to terminate an snprintf'ed buffer
      lnstat_util: Make sure buffer is NUL-terminated
      lib/bpf: Fix bytecode-file parsing

Philip Prindeville (1):
      iproute2: add support for GRE ignore-df knob

Roopa Prabhu (2):
      ip: extend route get to return matching fib route
      iproute: extend route get for mpls routes

Simon Horman (1):
      tc actions: store and dump correct length of user cookies

Stephen Hemminger (27):
      update to current net-next headers
      update headers to get changes for TCA_FLOWER
      update headers to get IFLA_EVENT
      updated headers from net-next
      update headers from net-next (bpf and tc)
      more bpf header updates
      update headers to get TCA_TUNNEL_CSUM
      update kernel headers from net-next
      update headers to 4.13-rc1
      remove duplicated #include's
      Update headers from net-next
      ip: change flag names to an array
      update headers from 4.13-rc4
      tc: fix m_simple usage
      iproute: Add support for extended ack to rtnl_talk
      ss: enclose IPv6 address in brackets
      lib: fix extended ack with and without libmnl
      lib: need to pass LIBMNL flag
      tc, ip: more Makefile updates for LIBMNL
      vti6: fix local/remote any addr handling
      change how Config is used in Makefile's
      vti: print keys in hex not dotted notation
      rdma: fix duplicate initialization in port_names
      libnetlink: drop unused parameter to rtnl_dump_done
      bpf: drop unused parameter to bpf_report_map_in_map
      tc: use named initializer for default mqprio options
      v4.13.0

Vlad Yasevich (1):
      ip: Add IFLA_EVENT output to ip monitor

=C3=89lie Bouttier (1):
      ip route: replace exits with returns
