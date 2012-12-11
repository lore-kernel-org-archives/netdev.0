From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [ANNOUNCE] iproute2 3.7.0
Date: Tue, 11 Dec 2012 10:07:55 -0800
Message-ID: <20121211100755.3ffb030c@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Just in time for the holidays, an update to iproute2 for v3.7 kernel.
In addition to lots of build and documentation fixes, this
version includes support for tcp_metrics and vxlan
documentation and minor bugfixes,

If you have been sitting on changes to iproute2 that are in
net-next for 3.8 merge window, please submit them now.

Iproute2 package is available at:
  http://kernel.org/pub/linux/utils/net/iproute2/iproute2-3.7.0.tar.gz

You can download the source from:
  git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git

Stay Warm!

---

Andreas Henriksson (2):
      iproute2: avoid errors from double-installing manpages
      iproute2: drop libresolv

Julian Anastasov (1):
      iproute2: add support for tcp_metrics

Matt Burgess (1):
      iproute2-3.6.0 assumes presence of iptables

Mike Frysinger (1):
      allow pkg-config to be customized

Nicolas Dichtel (4):
      iproute2: inform user when a neighbor is removed
      ip/ip6tunnel: fix help for TCLASS
      ip/ip6tunnel: reset encap limit flag on change
      ip/ip6tunnel: fix update of tclass and flowlabel

Or Gerlitz (1):
      iplink: Added support for the kernel IPoIB RTNL ops

Pavel Emelyanov (4):
      ss: Rename some tcp- names into inet-
      ss: Split inet_show_netlink into parts
      ss: Support sock-diag
      ss: Get udp sockets info via sock-diag

Petr P=C3=ADsa=C5=99 (1):
      iproute2: List interfaces without net address by default

Petr Sabata (1):
      iproute2: ss - change default filter to include all socket types

Rostislav Lisovy (1):
      tc: add canid ematch to ematch_map

Stephen Hemminger (12):
      vxlan support
      bridge: manage VXLAN based forwarding tables
      l2tp: remove references to old bridge utils
      Update headers to 3.7-pre-rc
      vxlan: add support for port range
      vxlan: only send group address if defined
      Update kernel headers to 3.7-rc1
      iplink: add vxlan to man page
      bridge: remove trailing whitespace
      bridge: use rta_getattr_xxx wrappers
      man: fix incorrect use of "it's"
      v3.7.0

Vincent Bernat (1):
      ip: fix "ip -6 route add ... nexthop"

Wookey (1):
      configure: respect $CC environment var override
