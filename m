From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [ANNOUNCE] iproute2 v3.18
Date: Wed, 24 Dec 2014 12:55:18 -0800
Message-ID: <20141224125518.4fcd67ed@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: lkml@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:47808 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751512AbaLXUz3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Dec 2014 15:55:29 -0500
Received: by mail-pd0-f172.google.com with SMTP id y13so10513559pdi.3
        for <netdev@vger.kernel.org>; Wed, 24 Dec 2014 12:55:28 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just in time for those last minute gifts!
Update to iproute2 for 3.18

Lots of activity around switching, ss command output and usual
set of documentation fixes. Vadim has also revived the long ignored
tests.

Source:
  http://www.kernel.org/pub/linux/utils/net/iproute2/iproute2-3.18.0.tar.gz

Repository:
  git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git

Report problems (or enhancements) to the netdev@vger.kernel.org mailing list.

---
Alexey Andriyanov (1):
      iproute2: ip6_tunnel mode bugfixes: any,vti6

Christian Hesse (3):
      ip-link: add switch to show human readable output
      ip-link: fix column alignment
      ip-link: in human readable output use dynamic precision length

Daniel Borkmann (1):
      ss: output dctcp diag information

Dave Taht (1):
      iproute2: Add support for babel protocol table entry

Eric Dumazet (2):
      netlink: extend buffers to 16K
      iproute2/nstat: Bug in displaying icmp stats

Florian Westphal (1):
      utils: relax strtoX checking in get_time_rtt

Heiner Kallweit (1):
      ip: allow ip address show to list addresses with certain flags not being set

Jiri Pirko (2):
      add bridge_slave device support
      add bridge master device support

Masatake YAMATO (1):
      man: ip-link: fix a typo

Nicolas Dichtel (2):
      man: update doc after support of ESN and anti-replay window
      ipaddress: enable -details option

Nikita Edward Baruzdin (1):
      iproute2: Add support for CAN presume-ack feature

Or Gerlitz (1):
      ip-link: Document IPoIB link type in the man page

Pavel Simerda (1):
      ip route: don't assume default route

Scott Feldman (1):
      bridge/fdb: fix statistics output spacing

Stephen Hemminger (15):
      update headers to 3.17.0 net-next
      Update kernel headers to 3.18-rc2
      ip: add iec formatted option and cleanup code
      update if_bridge
      rt_dsfield: fix Expedited Forwarding PHB
      tunnel: decode ESP tunnel type
      tc: minor spelling fixes
      ip-link: fix unterminated string in manpage
      add local version of linux/in6.h
      need libc-compat.h for new in6.h
      if_bridge: remove in6.h
      rt_names can't be const
      resolve header file conflict betwen linux/in6.h and netinet/in.h
      whitespace cleanup
      v3.18.0

Tom Herbert (5):
      ip fou: Support to configure foo-over-udp RX
      ip link ipip: Add support to configure FOU and GUE
      ip link gre: Add support to configure FOU and GUE
      iproute2: Man pages for fou and gue
      vxlan: Add support for enabling UDP checksums

Vadim Kochan (4):
      ip link: Allow to filter devices by master dev
      ss: Dont show netlink and packet sockets by default
      ip lib: Added shorter timestamp option
      ip link: Show devices by type

dingzhi (1):
      xfrm: add support of ESN and anti-replay window

vadimk (24):
      man ip-link: Fixed missing 'up' option in 'ip link show' synopsis
      doc make: Add *.pdf files to the 'clean' target
      gitignore: Ignore 'doc' files generated at runtime
      man ip: Add missing '-details' option
      tests: Skip cls-testbed.t if tests/cls dir does not exist
      tests: Allow to run tests recursively
      doc ip-cref: Added missing ip options
      ss: Identify more netlink protocol names
      ip monitor: Allow to filter events by dev
      tests: Move tc related tests to testsuite/tests/tc folder
      ip netns: Identify netns for the current process
      ss: Remove checking SS_CLOSE state for packet and netlink
      ss: Fixed broken output for Netlink 'Peer Address:Port' column
      ss: Refactor to use macro for define diag nl request
      man ip-link: Add description for 'help' command
      ss: Use generic handle_netlink_request for packet
      configure: Add check for the doc tools
      man ip-link: Fix indentation for 'ip link show' options
      ip monitor: Fix issue when timestamp is printed w/o msg
      ss: Fix layout/output issues introduced by regression
      lib names: Use CONFDIR for specify 'group' file path
      lib names: Add helper func for parse id and name from file
      ss: Use nl_proto_a2n for filtering by netlink proto
      ss: Use rtnl_dump_filter in handle_netlink_request
