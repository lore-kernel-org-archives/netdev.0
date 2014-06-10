From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [ANNOUNCE] iproute2 3.15.0 release
Date: Tue, 10 Jun 2014 10:37:12 -0700
Message-ID: <20140610103712.57d0b1ad@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Time for the release of iproute2 for 3.15

The main new features are:
  * ss gets more attention
  * Support for HHF qdisc
  * Updates to bridge command
  * Lots of vxlan related changes
  * Lots of little corrections and build fixes

Source:
  http://www.kernel.org/pub/linux/utils/net/iproute2/iproute2-3.15.0.ta=
r.gz

Repository:
  git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git

Report problems (or enhancements) to the netdev@vger.kernel.org mailing=
 list.

---
Adam Borowski (1):
      ip: fix build failure if time_t is not long int

Alexander Duyck (1):
      iproute2: act_ipt fix xtables breakage on older versions.

Amerigo Wang (1):
      iptunnel: check SIT_ISATAP flag only for SIT tunnel

Andreas Greve (1):
      fix print_ipt: segfault if more then one filter with action -j MA=
RK.

Andreas Henriksson (4):
      iproute2: fix build failure on sparc due to -Wformat and tv_usec
      ss: avoid passing negative numbers to malloc
      ss: avoid passing negative numbers to malloc
      bridge: Make filter_index match in signedness

Andrey Vagin (5):
      ip: set the close-on-exec flag for descriptors
      ss: handle socket diag request in a separate function
      ss: create a function to print info about netlink sockets
      ss: show destination address for netlink sockets
      ss: Get netlink sockets info via sock-diag (v2)

Arvid Brodin (1):
      ip: Add HSR support

Atzm Watanabe (1):
      vxlan: Allow setting destination to unicast address.

Christoph Paasch (3):
      tcp_metrics: Rename addr to daddr and add local variable
      tcp_metrics: Display source-address
      tcp_metrics: Allow removal based on the source-IP

Christophe Gouault (1):
      xfrm: enable to set non-wildcard mark 0 on SAs and SPs

Cong Wang (2):
      add quickack option to ip route
      do not exit silently when link is not found

Daniel Borkmann (2):
      ip: ipv6: add tokenized interface identifier support
      tc: add cls_bpf frontend

David L Stevens (1):
      iproute2: support NTF_ROUTER flag in VXLAN fdb entries

David Stevens (1):
      iproute2: generalize VXLAN forwarding tables

Eric Dumazet (11):
      ss: add fastopen support
      htb: report overhead attribute
      get_rate: detect 32bit overflows
      ss: add more TCP_INFO components
      pkt_sched: fq: Fair Queue packet scheduler
      pkt_sched: fq: Fair Queue packet scheduler
      tc: support TCA_STATS_RATE_EST64
      htb: add support for direct_qlen attribute
      htb: support 64bit rates
      tc: more user friendly rates
      ss: display pacing_rate/max_pacing_rate

=46X Le Bail (1):
      ss: display interface name as zone index when needed

=46an Du (1):
      xfrm: use memcpy to suppress gcc phony buffer overflow warning.

Hangbin Liu (3):
      ipaddrlabel: use uint32_t instead of int32_t
      ipaddrlabel: use uint32_t instead of int32_t
      iptunnel: Allow GRE_KEY for vti interface

Heiner Kallweit (1):
      ip: officially support flag mngtmpaddr also for "ip addr del"

Hiroaki SHIMODA (1):
      htb: Move direct_qlen code part to htb_parse_opt().

Jamal Hadi Salim (11):
      tc: introduce simple action
      action: typo nat fix
      skbedit to default to pipe
      skbedit print missing metadata
      policer - retire old syntax
      simple print newline
      allow batch gets of actions
      dont skip action order
      Remove unnecessary debug statement
      actions: keyword flowid or classid terminates action pipeline
      actions: correctly report the number of actions flushed

Jay Vosburgh (1):
      tc/netem: fix loss state display and p14 parsing

Jesper Dangaard Brouer (1):
      linklayer interface between kernel and tc/userspace

Jiri Pirko (8):
      iplink: add support for bonding netlink
      add support for extended ifa_flags
      add support for IFA_F_MANAGETEMPADDR
      introduce support for slave info data
      iplink: add support for bonding slave
      iproute2: ipa: show port id
      iproute2: arpd: use ll_addr_a2n and ll_addr_n2a
      iproute2: utils: change hexstring_n2a and hexstring_a2n to do not=
 work with ":"

John Fastabend (2):
      iproute2: bridge: fix 'bridge link' setlink/getlink parsing
      iproute2: add man page for mqprio

JunweiZhang (1):
      ipbatch: fix use of 'ip netns exec'

Kamil Rytarowski (1):
      iproute2 patch against GCC 4.8.0

Kusanagi Kouichi (1):
      veth: Handle flags correctry

Lutz Jaenicke (1):
      macvlan: fix typo in macvlan_print_opt()

Martin Schwenke (1):
      ip: Add label option to ip monitor

Masatake YAMATO (7):
      ss: handle seqpacket type of unix domain socket
      ss: enable query by type in unix domain related socket
      ss: add unix_seqpacket to the help message and the man page
      genl: fix a typo in help message of ctrl
      iproute2: use named constants instead of number literals to fill =
rtnl_rtscope_tab
      iproute2: use named constants instead of number literals to fill =
rtnl_rttable_hash
      iproute: Show default type, table, proto and scope of route

Michal Kube=C4=8Dek (3):
      iplink_bond: fix arp_all_targets parameter name in output
      iplink_bond: fix parameter value matching
      iplink_bond_slave: show mii_status only once

Mike Rapoport (2):
      bridge: fix reporting of IPv6 addresses
      ipnetns: fix misprint in an error message

Mythili Prabhu (1):
      PIE: Add man page

Natanael Copa (1):
      iproute2: various header include fixes for compiling with musl li=
bc

Nicolas Dichtel (10):
      ip: add missing help about mode argument
      ip/xfrm: all to set flag XFRM_SA_XFLAG_DONT_ENCAP_DSCP
      ipnetconf: by default dump all entries
      ss: allow to retrieve AF_PACKET info via netlink
      man: describe --bpf option of ss
      ipadress: fix display of IPv6 peer address
      ip: allow to specify mode for sit tunnels
      ipnetns: fix ip batch mode when using 'netns exec'
      iplink: update available type list
      ipxfrm: allow to setup filter when dumping SA

Nigel Kukard (1):
      Fix tc stats when using -batch mode

Oliver Hartkopp (3):
      iproute2: can: fix indention white spaces
      iproute2: can: support CAN FD control interface
      iplink: can: fix help text and man page

Or Gerlitz (1):
      Document VF link state control in the ip-link man page

Patric McHardy (1):
      ip: iplink_vlan: add 802.1ad support

Pavel Emelyanov (4):
      ss: Show inet and unix sockets' shutdown state
      iproute: Make it possible to specify index on link creation
      iproute: Document the "ip link add index IDX" possibility
      iproute: Fix Netid value for multi-families output

Petr P=C3=ADsa=C5=99 (2):
      iproute2: bridge: document mdb
      iproute2: bridge: Close file with bridge monitor file

Rami Rosen (1):
      ss: replace bfp with bpf in usage().

Richard Godbee (3):
      iproute2: iproute.c: fix usage() spacing problems
      iproute2: spelling: noptmudisc -> nopmtudisc
      iproute2: ip-route.8.in: minor fixes

Richard Haines (1):
      ss: Add support for retrieving SELinux contexts

Rony Efraim (1):
      Add VF link state control

Sami Kerola (2):
      ip: make -resolve addr to print names rather than addresses
      ip: make -resolve addr to print names rather than addresses

Sergey Popovich (1):
      Handle netdev group for veth peer too

Sergey V. Lobanov (3):
      Fix Linux priority and band for TOS=3D=3D0x2 (man 8 tc-prio)
      TBF man page fix (tbf is not classless)
      Fixed 'tc qdisc show' for tbf when latency<0

Sriram Narasimhan (1):
      iptuntap: allow creation of multi-queue tun/tap device

Stefan Tomanek (2):
      ip link: fix display of interface groups
      ip rule: add route suppression options

Stephen Hemminger (59):
      Update headers to 3.10
      Add vxlan destination port option
      vxlan: nag user to set port value
      add BPF header files
      vxlan: remove dstport option
      man: get rid of useless reference to GNU style options
      htb: fix indentation
      update to 3.10-net-next headers
      netns: follow return value conventions of the rest of the code
      ip: add batch mode to man page
      Make tc and ip batch mode consistent
      v3.10.0
      Update to 3.11-rc1 kernel headers
      Remove -Werror
      Update kernel headers to net-next for 3.12
      cleanup help message
      Fix spelling errors
      More minor spelling fixes
      tc: allow qdisc without options
      add ability to filter neighbour discovery by protocol
      Update kernel headers to 3.11
      v3.11.0
      Update to 3.11 net-next kernel headers
      nstat: add json output format
      Update to 3.12-rc1 headers
      nstat: revise json output
      ifstat: add json output format
      lnstat: add json output format
      lnstat, nstat, ifstat: update man pages
      tc: add default action to kernel headers
      ipv6 gre: add entry to ether types
      Fix handling of qdis without options
      htb: remove old unused duplicate qdisc name
      update kernel headers
      Update kernel headers
      v3.12.0
      update kernel headers to 3.13-rc1
      update to net-next headers
      Update headers to 3.13-rc2
      Fix FSF address in file headers
      Update header files to 3.13-rc2 net-next
      netconf: add support for neighbor proxy attribute
      check return value of rtnl_send and related functions
      veth: fix uninitialized arguments
      update to latest net-next headers
      Update to 3.13-rc6 + net-next headers
      Revert "vxlan: remove dstport option"
      Update headers files from net-next
      Update kernel headers to 3.13-rc2
      Remove trailing whitespace
      kill spaces before tabs
      Update headers to net-next
      fix indentation of ip neighbour man page
      v3.14.0
      Update to 3.15-rc2 headers
      Whitespace and indentation cleanup
      fix format warnings
      Fix non-literal string format warnings
      v3.15.0

Terry Lam (1):
      support for Heavy Hitter Filter (HHF) qdisc

Thomas Egerer (1):
      ip/xfrm: Fix potential SIGSEGV when printing extra flags

Thomas Haller (1):
      add support for IFA_F_NOPREFIXROUTE

Thomas Richter (3):
      iproute2 vxlan documentation update for bridge command
      iproute2 vxlan documentation update for ip command
      iproute vxlan add support for fdb replace command

Vijay Subramanian (1):
      PIE: Proportional Integral controller Enhanced

Vlad Yasevich (1):
      bridge: Add learning and flood support

WANG Cong (3):
      vxlan: add ipv6 support
      pedit: do not print debugging information by default
      ipaddress: do not add IFA_FLAGS when not necessary

Yang Yingliang (4):
      tbf: add 64bit rates support
      tbf: support sending burst/mtu to kernel directly
      netem: add 64bit rates support
      fq: allow options of fair queue set to ~0U

david decotigny (1):
      iproute2: show counter of carrier on<->off transitions

esr@thyrsus.com (4):
      First set of manpage markup fixes
      tc-stab.8: Fix synopsis errors, an invalid escape, and incorrect =
English usge.
      In tc-ematch.8, remove no-op .ti requests to prevent translation =
warnings
      ip-rule.8: Fix presentational use of .SS.

sfeldma@cumulusnetworks.com (1):
      iproute2: finish support for bonding attributes

xeb@mail.ru (2):
      iproute2: GRE over IPv6 tunnel support.
      iproute2: ip6gre: update man pages
