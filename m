From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [ANNOUNCE] iproute2 4.7.0
Date: Mon, 8 Aug 2016 09:27:46 -0700
Message-ID: <20160808092746.4f7a80cd@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update to iproute2 utility to support new features in Linux 4.7.
New features are support of JSON output for bridge command, and configuring macsec.
Plus the usual array of documentation, support of kernel flags and minor fixes.

Source:
  http://www.kernel.org/pub/linux/utils/net/iproute2/iproute2-4.7.0.tar.gz

Repository:
  git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git

Report problems (or enhancements) to the netdev@vger.kernel.org mailing list.

---
Alexander Aring (1):
      tc: let m_ipt work with new iptables API headers

Amir Vadai (1):
      tc: flower: Add skip_{hw|sw} support

Andrew Vagin (1):
      ip route: timeout for routes has to be set in seconds

Anuradha Karuppiah (3):
      json_writer: Removed automatic json-object type from the constructor
      bridge: add json support for bridge fdb show
      bridge: add json schema for bridge fdb show

Beniamino Galvani (1):
      utils: fix hex digits parsing in hexstring_a2n()

Daniel Borkmann (4):
      ingress, clsact: don't add TCA_OPTIONS to nl msg
      f_bpf: fix filling of handle when no further arg is provided
      ip, token: add del command
      bpf: also check elf for official e_machine value

David Ahern (13):
      Make builds default to quiet mode
      man: ip-link: Add vrf type
      ss: Refactor inet_show_sock
      ss: Allow ssfilter_bytecompile to return 0
      ss: Add support to filter on device
      ip vrf: Add name_is_vrf
      ip link/addr: Add support for vrf keyword
      ip neigh: Add support for keyword
      ip route: Change type mask to bitmask
      ip vrf: Add ipvrf_get_table
      ip route: Add support for vrf keyword
      ss: Fix support for device filter by index
      ss: Add option to suppress header line

Davide Caratti (3):
      man: macsec: fix macsec related typos
      ip {link,address}: add 'macsec' item to TYPE list
      macsec: cipher and icvlen can be set separately

Eli Cohen (1):
      Add support for configuring Infiniband GUIDs

Eric Dumazet (2):
      ss: add SK_MEMINFO_DROPS display
      fq_codel: add per queue memory limit

Fabien Siron (1):
      misc/ss: Add family list to -f option in _usage()

Ido Schimmel (2):
      man: Add devlink man pages to Makefile
      man: Point to 'devlink-sb' from 'devlink' man page

Jakub Sitnicki (1):
      ip/tcp_metrics: Simplify process_msg a bit

Jamal Hadi Salim (6):
      tc fix ife late binding
      tc simple action: bug fix
      tc action policer: Avoid nonsensical input
      tc filter u32: Coding style fixes
      tc action policer: enable timestamp display
      action pedit: stylistic changes

Jiri Benc (3):
      vxlan: 'external' implies 'nolearning'
      ip-link.8: document "external" flag for vxlan
      vxlan: add support for VXLAN-GPE

Jiri Pirko (4):
      devlink: implement shared buffer support
      devlink: implement shared buffer occupancy control
      devlink: write usage help messages to stderr
      devlink: add option to generate JSON output

Kylie McClain (1):
      ipaddress: fix build with musl libc

Lucas Bates (1):
      man: tc-ife.8: man page for ife action

Martin KaFai Lau (1):
      ss: Add tcp_info fields data_segs_in/out

Masatake YAMATO (1):
      man: rtacct: add missing TP marker

Michal Soltys (2):
      iproute2: unmangle netdev/my emails in man pages (hfsc, stab)
      man/man8/tc-flow.8: minor corrections

Peter Heise (2):
      Added support for selection of new HSR version
      man: ip-link: Added HSR part

Phil Sutter (42):
      man: ip, ip-link: Fix ip option location
      man: rtpr: Fix minor typo
      ipaddress: Allow listing addresses by type
      man: ip-link: Document query_rss option
      tc: m_xt: Prevent segfault with standard targets
      tc: m_xt: Fix segfault when adding multiple actions at once
      tc: m_xt: Fix indenting
      tc: m_xt: Get rid of one indentation level in parse_ipt()
      tc: m_xt: Drop unused variable fw in parse_ipt()
      tc: m_xt: Get rid of rargc in parse_ipt()
      tc: m_xt: Get rid of iargc variable in parse_ipt()
      tc: m_xt: Simplify argc adjusting in parse_ipt()
      tc: m_xt: Introduce get_xtables_target_opts()
      tc: m_action: Use C99 style initializers for struct req
      tc: m_action: Drop unused variable nladdr in tc_action_gd()
      iplink: Add missing variable initialization
      iplink: Check address length via netlink
      man: ip-address, ip-link: Document 'type' quirk
      Fix MAC address length check
      Use ARRAY_SIZE macro everywhere
      ip-address: Support filtering by slave type, too
      ip-address: Align type list in help and man page
      ip-address: constify match_link_kind arg
      iplink: List valid 'type' argument in ip link help text
      iplink: bond_slave: Add missing help functions
      ip-link.8: Extend type list in synopsis
      ip-link.8: Place 'ip link set' warning more prominently
      ip-link.8: Add slave type option descriptions
      ip-link.8: Fix font choices
      tc: m_action: Improve conversion to C99 style initializers
      Use C99 style initializers everywhere
      Replace malloc && memset by calloc
      No need to initialize rtattr fields before parsing
      Makefile: Allow to override CC
      tc: ematch: Ignore all-zero mask value when printing filters
      ip-address.8: Document autojoin flag
      tc: Reformat tc_util.h
      tc: util: bore up action_a2n()
      tc: use action_a2n() everywhere
      tc: util: No need for action_n2a() to be reentrant
      tc: Fix for missing estimator initialization
      tc/m_gact: Fix action_a2n() return code check

Roopa Prabhu (3):
      bridge: add json support for bridge vlan show
      bridge: update man page
      bridge: vlan json: skip ports with empty vlans

Sabrina Dubroca (4):
      utils: make hexstring_a2n provide the number of hex digits parsed
      utils: add get_be{16, 32, 64}, use them where possible
      utils: provide get_hex to read a hex digit from a char
      ip: add MACsec support

Samudrala, Sridhar (1):
      tc: f_u32: Add support for skip_hw and skip_sw flags

Shanker Wang (1):
      l2tp: add udp checksum control flags

Stephen Hemminger (19):
      update kernel headers
      update inet_diag.h header
      update kernel headers from net-next
      update kernel headers from net-next
      devlink: update uapi header
      update kernel headers from net-next
      update kernel headers (from 4.7-rc1)
      add if_macsec header
      tc: action result is u32
      tc: update headers for TCA_POLICE
      ip: minor checkpatch cleanup
      tc: f_u32 cleanup indentation and long lines
      pedit: fix whitespace etc
      m_xt: whitespace cleanup
      if: add missing kernel headers
      ip: link style cleanup
      iproute: constify rtattr_cmp
      bridge: remove unused variable
      v4.7.0

Vivien Didelot (4):
      bridge: vlan: fix a few "fdb" typos in vlan doc
      bridge: man: fix "brige" typo
      bridge: man: fix BPUD typo
      bridge: man: fix STP LISTENING description

Xin Long (1):
      ip route: restore route entries in correct order
