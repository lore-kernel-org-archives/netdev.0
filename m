From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [ANNOUNCE] iproute2 4.6
Date: Wed, 18 May 2016 12:01:56 -0700
Message-ID: <20160518120156.3ab0e3d1@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lkml@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:35791 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752006AbcERTBo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2016 15:01:44 -0400
Received: by mail-pa0-f45.google.com with SMTP id tb2so3030254pac.2
        for <netdev@vger.kernel.org>; Wed, 18 May 2016 12:01:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update to iproute2 utility to support new features in Linux 4.5.
Major things are improvements to bridg mdb management, and bpf.
Also, support for new devlink infrastructure

Source:
  http://www.kernel.org/pub/linux/utils/net/iproute2/iproute2-4.6.0.tar.gz

Repository:
  git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git

Report problems (or enhancements) to the netdev@vger.kernel.org mailing list.

---
Daniel Borkmann (5):
      vxlan: add support to set flow label
      geneve: add support to set flow label
      tc, bpf: add new csum and tunnel signatures
      tc, bpf: further improve error reporting
      tc, bpf: add support for map pre/allocation

David Ahern (2):
      vrf: Add support for slave_info
      ip link: Add support for kernel side filtering

Edward Cree (1):
      geneve: fix IPv6 remote address reporting

Elad Raz (1):
      bridge: mdb: add support for offloaded mdb entries

Eric Dumazet (2):
      iplink: display number of rx/tx queues
      ss: take care of unknown min_rtt

Gustavo Zacarias (1):
      iproute2: tc_bpf.c: fix building with musl libc

Jamal Hadi Salim (3):
      tc: introduce IFE action
      tc: don't ignore ok as an action branch
      tc simple action update and breakage

Jeff Harris (1):
      ip: neigh: Fix leftover attributes message during flush

Jesse Gross (2):
      vxlan: Follow kernel defaults for outer UDP checksum.
      geneve: Add support for configuring UDP checksums.

Jiri Benc (2):
      ip link gre: create interfaces in external mode correctly
      ip link gre: print only relevant info in external mode

Jiri Pirko (13):
      include: add linked list implementation from kernel
      add devlink tool
      devlink: fix "devlink port" help message
      list: add list_for_each_entry_reverse macro
      list: add list_add_tail helper
      devlink: introduce pr_out_port_handle helper
      devlink: introduce helper to print out nice names (ifnames)
      devlink: split dl_argv_parse_put to parse and put parts
      devlink: introduce dump filtering function
      devlink: allow to parse both devlink and port handle in the same time
      devlink: add manpage for shared buffer

Luca Lemmo (3):
      tc: f_u32: add missing spaces around operators
      tc: f_u32: trivial coding style cleanups
      tc: q_{codel,fq_codel}: add missing space in help text

Marco Varlese (1):
      fix get_addr() and get_prefix() error messages

Nicolas Dichtel (1):
      iplink: display IFLA_PHYS_PORT_NAME

Nikolay Aleksandrov (5):
      bridge: mdb: add user-space support for extended attributes
      bridge: mdb: add support for extended router port information
      bridge: fdb: add support to filter by vlan id
      bridge: mdb: add support to filter by vlan id
      bridge: vlan: add support to filter by vlan id

Phil Sutter (22):
      tc/p_ip.c: Minor coding style cleanup
      tc: pedit: Fix for big-endian systems
      tc: pedit: Fix raw op
      testsuite: add a test for tc pedit action
      doc/tc-filters.tex: Drop overly subjective paragraphs
      tc: connmark, pedit: Rename BRANCH to CONTROL
      man: tc-csum.8: Add an example
      man: tc-mirred.8: Reword man page a bit, add generic mirror example
      man: tc-police.8: Emphasize on the two rate control mechanisms
      man: tc-skbedit.8: Elaborate a bit on TX queues
      tc/m_vlan.c: mention CONTROL option in help text
      man: tc-vlan.8: Describe CONTROL option
      color: introduce color helpers and COLOR_CLEAR
      ipaddress: colorize peer, broadcast and anycast addresses as well
      make format_host non-reentrant by default
      utils: make rt_addr_n2a() non-reentrant by default
      lib/utils: introduce format_host_rta()
      lib/utils: introduce rt_addr_n2a_rta()
      lib/ll_addr: improve ll_addr_n2a() a bit
      ip-link: Support printing VF trust setting
      ss: Drop silly assignment
      ss: Fix accidental state filter override

Quentin Monnet (1):
      tc: add bash-completion function

Stephen Hemminger (22):
      Update header files from net-next
      iplink: display rx nohandler stats
      ss: display not_sent and min_rtt info
      tc: code cleanup
      ip: code cleanup
      bridge: code cleanup
      misc: fix style issues
      update kernel headers to 4.6 (pre rc1)
      netconf: replace macro with a function
      scrub out whitespace issues
      devlink: ignore build result
      ip: only display phys attributes with details option
      ip: whitespace cleanup
      devlink: remove unused code
      devlink: remove more unused code
      vv4.6.0

Zhang Shengju (2):
      man: update netconf manual for new attributes
      netconf: add support for ignore route attribute

subashab@codeaurora.org (1):
      ss: Remove unused argument from kill_inet_sock
