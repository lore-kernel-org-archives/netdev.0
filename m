From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [ANNOUNCE] iproute2 4.0.0
Date: Mon, 13 Apr 2015 09:38:58 -0700
Message-ID: <20150413093858.5dc048e7@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

4.0 kernel is now released and this is the corresponding iproute2. Ther=
e are the
usual array of manual and small bugfixes. A log of the changes have bee=
n
around better support of network namespaces, BPF and the ss command.

Source:
  http://www.kernel.org/pub/linux/utils/net/iproute2/iproute2-4.0.0.tar=
=2Egz

Repository:
  git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git

Report problems (or enhancements) to the netdev@vger.kernel.org mailing=
 list.

---
Alex Pilon (1):
      Allow specifying bridge port STP state by name rather than number=
=2E

Andy Gospodarek (1):
      bridge: drop reference to unused option embedded from manpage

Bryton Lee (1):
      prevent the read ahead of /proc/slabinfo in ss

Daniel Borkmann (3):
      ip: route: add congestion control metric
      m_bpf: remove unrelevant help lines
      tc: m_bpf: fix next arg selection after tc opcode

Ebben Aries (1):
      iproute: ip-gue/ip-fou manpages

Eric Dumazet (1):
      ss: better 32bit support

Hagen Paul Pfeifer (1):
      ss: group DCTCP socket statistics

Jiri Benc (1):
      configure: add missing INCLUDE to netnsid detection

Jiri Pirko (2):
      tc: push bpf common code into separate file
      tc: add support for BPF based actions

Lennart Sorensen (1):
      Fix misspelling of defrag in ip-l2tp.8

Mark Einon (1):
      ip: Make uniform the use of synonyms list, show and lst

Nicolas Dichtel (7):
      ipnetns: allow to get and set netns ids
      iplink: add support of IFLA_LINK_NETNSID attribute
      bridge/fdb: display link netns id
      ip-monitor: allow to monitor ip rules
      Revert "configure: add missing INCLUDE to netnsid detection"
      Revert "ip netns: Fix rtnl error while print netns list"
      ipnetns: add a runtime check for RTM_GETNSID support

Pavel =C5=A0imerda (1):
      docs: make spacing consistent

Roopa Prabhu (5):
      iproute2: bridge: support vlan range adds
      iproute2: bridge vlan show new option to print ranges
      bridge link: add support to specify master
      fix ip -force -batch to continue on errors
      lib utils: fix family during af_bit_len calculation

Stephen Hemminger (4):
      update kernel headers to 3.19 net-next
      update kernel headers based on net-next 3.21
      update headers to 3.20-rc1
      v4.0.0

Thomas Graf (1):
      vxlan: Group policy extension

Vadim Kochan (29):
      ss: Show stats from specified network namespace
      ss: Fix filter expression parser
      ss: Split tcpstap struct to sockstat & tcpstat
      ss: Replace pktstat struct by new sockstat struct
      ss: Replace unixstat struct by new sockstat struct
      ss: Unify state socket output:netid, state, rq, wq
      ss: Unify details info output:ino,uid,sk
      ss: Unify socket address output by one generic func
      ss: Fixed wrong tcp ato value from netlink
      ip xfrm: Allow to specify "all" option for monitor
      ip xfrm mon: Add objects list to the usage output
      ss: Add filter before printing unix stats from Netlink
      ss: Skip filtered netlink sockets before detailed info
      man ip-link: Add short info about 'dynamic' flag
      man ip-link: Add notice about local netns devices
      man ip-link: Add short description about 'group'
      man tc: Highlight minor & major, notice they are hex
      man ip-netns: Notice about loose device when do 'del'
      ss: Allow to specify sport/dport without ':'
      lib utils: Use helpers to get AF bit/byte len
      ip netns: Fix rtnl error while print netns list
      tc class: Show class names from file
      man ip-link: Add ip-netns(8) in 'SEE ALSO'
      man ip-netns: Fix syntax in default ns process, indent's
      tc class: Ignore if default class name file does not exist
      man ip-netns: Fix shifted layout at bottom of 'ip netns del'
      ip-link: Align usage at [link-netns ID] line
      man ip-link: Add missing link types - vti,ipvlan,nlmon
      man tc: Add description about class name option

philipp@redfish-solutions.com (1):
      xfrm: Fix -o (oneline) being broken in xfrm and correct mark radi=
x
