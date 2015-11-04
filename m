From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [ANNOUNCE] iproute2 4.3.0
Date: Tue, 3 Nov 2015 16:40:56 -0800
Message-ID: <20151103164056.4c8db573@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Release of iproute2 for Linux 4.3

Update to iproute2 utility to support new features in Linux 4.3.
There are the usual array of small fixes to output and formatting.
Phil Sutter has done a lot of work on manual pages and getting Redhat
patches merged.

Source:
  http://www.kernel.org/pub/linux/utils/net/iproute2/iproute2-4.3.0.tar.gz

Repository:
  git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git

Report problems (or enhancements) to the netdev@vger.kernel.org mailing list.

---
Andrew Vagin (1):
      route: filter routes by family if it's specified

Anuradha Karuppiah (1):
      ip link: proto_down config and display.

Arthur Gautier (1):
      ip link: missing options in bond usage

Christoph Schulz (1):
      ip: allow using a device "help" (or a prefix thereof)

Christophe Gouault (1):
      batch: support quoted strings

Dan Webster (1):
      ss: fix file-based filtering segfault

Daniel Borkmann (2):
      m_bpf: add frontend support for late binding
      ip, realms: also allow to pass in raw realms value

David Ahern (2):
      add support for VRF device
      ip: Add type and master filters to brief output

Denis Kirjanov (1):
      iproute: print more verbose error on route cache flush

Eric Dumazet (2):
      tc : add timestamps to tc monitor
      tc: fq: allow setting and retrieving orphan_mask

Florian Westphal (1):
      man: tc: add man page for fq pacer

Kirill Tkhai (1):
      Add ip rule save/restore

Mike Saal (1):
      ss format bug

Nikolay Aleksandrov (4):
      bridge: mdb: add support for vlans
      bridge: mdb: add deleted when monitoring delmdb event
      iplink: bonding: add support for IFLA_BOND_TLB_DYNAMIC_LB
      iplink: add support for IFLA_BR_VLAN_FILTERING attribute

Phil Sutter (31):
      man: ip: add -h[uman-readable] option
      man: ip-address: align synopsis with help output
      comment: Fix remaining listings of wrong FSF address
      man: ip-address: document mngtmpaddr and noprefixroute flags
      man: lnstat: rewrite manpage
      man: rtpr: add minimal manpage
      ip-link: do not support 'ip link add dev help'
      man: tc.8: mention available qdiscs
      tc: fq: allow setting and retrieving flow refill delay
      ip: link: consolidate macvlan and macvtap
      ip: macvlan: support MACVLAN_FLAG_NOPROMISC flag
      man: ip-link: document MACVLAN/MACVTAP interface types
      ip-address: fix oneline mode for interfaces with VF
      ss: return -1 if an unrecognized option was given
      ip-rule: neither prohibit nor reject or unreachable flags exist
      tc: improve filter help texts a bit
      tc: u32 filter coding style cleanup
      tc: add a man page for basic filter
      tc: add a man page for cgroup filter
      tc: add a man page for flow filter
      tc: add a man page for flower filter
      tc: add a man page for fw filter
      tc: add a man page for route filter
      tc: add a man page for tcindex filter
      tc: add a man page for u32 filter
      tc: ship filter man pages and refer to them in tc.8
      ifcfg: add manpage
      genl: add manpage
      ifstat: add manpage
      bridge: fdb: minor syntax fix in help text
      lib/utils: improve error messages of get_addr() and get_prefix()

Richard Alpe (1):
      tipc: add man pages

Roopa Prabhu (3):
      libnetlink: introduce rta_nest and u8, u16, u64 helpers for nesting within rtattr
      ip monitor neigh: Change 'delete' to 'Deleted' to be consistent with ip route
      ip route get: change exit to return to support batch commands

Satish Ashok (1):
      ip, bridge: document -timestamp option

Stephen Hemminger (15):
      update to 4.2-net-next headers
      update kernel headers from net-next
      update to net-next (4.3) headers
      update header files from 4.2 net-next
      update kernel headers to 4.2-net-next
      update kernel headers to 4.2-net-next
      l2tp: add missing newline on show output
      fq: fix whitespace
      add tipc manpages to Makefile
      update kernel headers
      update kernel headers
      ip: remove extra newlines at end-of-file
      tc: remove extra whitespace
      misc: cleanup extra whitespace
      v4.3.0

Toshiaki Makita (1):
      iplink: Add support for IFLA_BR_VLAN_PROTOCOL attribute

Vadim Kochan (3):
      configure: Check for Berkeley DB for arpd compilation
      man ip-link: Fix wording in VLAN reorder_hdr explanation
      man tc-htb: Fix HRB -> HTB typo

Wilson Kok (2):
      bridge: add batch command support
      bridge: add calls to fflush in fdb and mdb print functions

willy tarreau (1):
      fix "ss -p" segfaults
