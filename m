From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [ANNOUNCE] iproute2 4.9
Date: Mon, 12 Dec 2016 15:24:27 -0800
Message-ID: <20161212152427.737b3861@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Release of iproute2 for Linux 4.9, just in time for your holiday
giving.

Update to iproute2 utility to support new features in Linux 4.9.
Mostly this is refinements to add new flags to tipc, l2tp, ss
and macsec support. There are also a couple of performance
enhancments for handling lots of interfaces and namespaces.

Source:
  https://www.kernel.org/pub/linux/utils/net/iproute2/iproute2-4.9.0.tar.gz

Repository:
  git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git

Report problems (or enhancements) to the netdev@vger.kernel.org mailing lis=
t.

---
Alexei Starovoitov (1):
      iptnl: add support for collect_md flag in IPv4 and IPv6 tunnels

Anton Aksola (1):
      iproute2: build nsid-name cache only for commands that need it

Asbj=C3=B8rn Sloth T=C3=B8nnesen (9):
      man: ip-l2tp.8: fix l2spec_type documentation
      man: ip-l2tp.8: remove non-existent tunnel parameter name
      l2tp: fix integers with too few significant bits
      l2tp: fix L2TP_ATTR_{RECV,SEND}_SEQ handling
      l2tp: fix L2TP_ATTR_UDP_CSUM handling
      l2tp: read IPv6 UDP checksum attributes from kernel
      l2tp: support sequence numbering
      l2tp: show tunnel: expose UDP checksum state
      man: ip-l2tp.8: document UDP checksum options

Craig Dillabaugh (1):
      action gact: list pipe as a valid action

Daniel Borkmann (1):
      tc, ipt: don't enforce iproute2 dependency on iptables-devel

Daniel Hopf (1):
      macsec: Nr. of packets and octets for macsec tx stats were swapped

Eric Dumazet (1):
      tc: fq: display unthrottle latency

Hadar Hen Zion (2):
      tc: flower: Introduce vlan support
      tc: m_vlan: Add priority option to push vlan action

Hangbin Liu (4):
      misc/ss: tcp cwnd should be unsigned
      ip rule: merge ip rule flush and list, save together
      ip rule: add selector support
      devlink: Convert conditional in dl_argv_handle_port() to switch()

Isaac Boukris (1):
      iproute2: ss: escape all null bytes in abstract unix domain socket

Jakub Kicinski (1):
      tc: cls_bpf: handle skip_sw and skip_hw flags

Jamal Hadi Salim (4):
      actions ife: Introduce encoding and decoding of tcindex metadata
      actions: add skbmod action
      man pages: Add tc-ife to Makefile
      tc filters: add support to get individual filters by handle

Lorenzo Colitti (1):
      ss: Support displaying and filtering on socket marks.

Lucas Bates (2):
      man pages: update ife action to include tcindex
      man pages: add man page for skbmod action

Mahesh Bandewar (1):
      ip: (ipvlan) introduce L3s mode

Mike Frysinger (1):
      ifstat/nstat: fix help output alignment

Moshe Shemesh (1):
      ip link: Add support to configure SR-IOV VF to vlan protocol 802.1ad =
(VST QinQ)

Neal Cardwell (1):
      ss: output TCP BBR diag information

Nikolay Aleksandrov (4):
      bridge: vlan: add support to display per-vlan statistics
      ipmroute: add support for age dumping
      bridge: vlan: remove wrong stats help
      bridge: add support for the multicast flood flag

Parthasarathy Bhuvaragan (7):
      tipc: remove dead code
      tipc: add link monitor set threshold
      tipc: add link monitor get threshold
      tipc: add link monitor summary
      tipc: refractor bearer to facilitate link monitor
      tipc: add link monitor list
      tipc: update man page for link monitor

Paul Blakey (1):
      tc: flower: Fix usage message

Phil Sutter (6):
      iproute: fix documentation for ip rule scan order
      include: Add linux/sctp.h
      ss: Add support for SCTP protocol
      ipaddress: Simplify vf_info parsing
      ipaddress: Print IFLA_VF_QUERY_RSS_EN setting
      man: ip-route.8: Add notes about dropped IPv4 route cache

Richard Alpe (3):
      tipc: add peer remove functionality
      tipc: introduce bearer add for remoteip
      tipc: add the ability to get UDP bearer options

Roi Dayan (2):
      devlink: Add usage help for eswitch subcommand
      devlink: Add option to set and show eswitch inline mode

Roman Mashak (7):
      ife action: allow specifying index in hex
      ife: print prio, mark and hash as unsigned
      ife: improve help text
      tc: updated man page to reflect GET command to retrieve a single filt=
er.
      tc: improved usage help for fw classifier.
      tc: print raw qdisc handle.
      tc: distinguish Add/Replace filter operations

Shmulik Ladkani (1):
      tc: m_vlan: Add vlan modify action

Simon Horman (1):
      ss: initialise variables outside of for loop

Stephen Hemminger (24):
      update headers to 4.8-rc2 net-next
      update TIPC headers
      tipc: cleanup style issues
      update kernel headers from net-next
      update bpf.h
      update headers from pre 4.9 (net-next)
      iplink: cleanup style errors
      ip: iprule style cleanup
      tc: skbmod style cleanup
      tc_filter: style cleanup
      ip: macvlan style cleanup
      Revert "iproute2: macvlan: add "source" mode"
      cleanup debris from revert
      ss: break really long lines
      ip: style cleanup
      tc: cleanup style of qdisc code
      update headers based on 4.9-rc7
      libnetlink: style cleanups
      l2tp: style cleanup
      Revert "devlink: Add option to set and show eswitch inline mode"
      Revert "devlink: Add usage help for eswitch subcommand"
      update kernel headers
      update to 4.9 release headers
      v4.9.0

Zhang Shengju (3):
      iproute2: fix the link group name getting error
      libnetlink: reduce size of message sent to kernel
      link: add team and team_slave link type

david decotigny (2):
      iproute2: avoid exit in case of error.
      iproute2: a non-expected rtnl message is an error

michael-dev@fami-braun.de (2):
      iproute2: macvlan: add "source" mode
      iproute2: macvlan: add "source" mode

stefan@datenfreihafen.org (1):
      ip: update link types to show 6lowpan and ieee802.15.4 monitor
