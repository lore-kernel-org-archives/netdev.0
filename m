From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [ANNOUNCE] iproute2 4.2.0
Date: Mon, 31 Aug 2015 16:39:34 -0700
Message-ID: <20150831163934.4f4d110b@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35088 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752390AbbHaXjX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2015 19:39:23 -0400
Received: by pacdd16 with SMTP id dd16so154281825pac.2
        for <netdev@vger.kernel.org>; Mon, 31 Aug 2015 16:39:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Regular release of iproute2 for Linux 4.2

Update to iproute2 utility to support new features in Linux 4.2.
Lots of work went into extending ss and bpf. Also some nicer
formatting in ip commands with brief mode.

Source:
  http://www.kernel.org/pub/linux/utils/net/iproute2/iproute2-4.2.0.tar=
=2Egz

Repository:
  git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git

Report problems (or enhancements) to the netdev@vger.kernel.org mailing=
 list.

---
Andy Gospodarek (2):
      iproute2: add support to print 'linkdown' nexthop flag
      add support for brief output for link and addresses

Antti Paila (1):
      ip: Preserve original portocol family in batch mode

Craig Gallek (2):
      ss: add support for segs_in and segs_out
      ss: Include -E option for socket destroy events

Daniel Borkmann (2):
      tc: {f,m}_bpf: add tail call support for parser
      tc: {f,m}_bpf: allow to retrieve uds path from env

David Ward (1):
      tc: gred: Add support for TCA_GRED_LIMIT attribute

Eran Ben Elisha (1):
      Add displaying VF traffic statistics

Eric Dumazet (2):
      ss: add support for bytes_acked & bytes_received
      codel: add ce_threshold support to codel & fc_codel

=46elix Janda (1):
      Replace BSD MAXPATHLEN by POSIX PATH_MAX

Gustavo Zacarias (1):
      tipc: make build conditional on having libmnl

Jan Engelhardt (1):
      build: must honor pkg-config flags for libmnl

Jiri Pirko (2):
      tc: add support for Flower classifier
      iproute2: ipa: show switch id

John W. Linville (4):
      iproute2: GENEVE support
      iproute2: update ip-link.8 for geneve tunnels
      iplink_geneve: add ttl configuration at link creation
      iplink_geneve: add tos configuration at link creation

Jonathan Toppins (1):
      iplink_bond: add support for ad_actor and port_key options

Konstantin Shemyak (1):
      add 'vti'/'vti6' tunnel modes to ip-tunnel manual page

Michal Kube=C4=8Dek (1):
      include: add copy of tipc.h

Nicolas Dichtel (6):
      man: update ip monitor page
      libnetlink: introduce rtnl_listen_filter_t
      ipmonitor: introduce print_headers
      ipmonitor: allows to monitor in several netns
      xfrmmonitor: allows to monitor in several netns
      tc: fix bpf compilation with old glibc

Nikolay Aleksandrov (7):
      bonding: export 3ad actor and partner port state
      iplink_bridge: add support for ageing_time
      iplink_bridge: add support for stp_state
      iplink_bridge: add support for priority
      ss: fix display of raw sockets
      bridge: mdb: add support for router add/del notifications monitor=
ing
      iplink: add ageing_time, stp_state and priority for bridge

Pavel =C5=A0imerda (3):
      ip: fix and extend documentation
      ip-link: fix and extend documentation
      ip-address: fix and extend documentation

Phil Sutter (10):
      ss: print value of IPV6_V6ONLY socket option if set
      misc/ss: don't imply -a when -A was specified
      ip-link: fix minor typo in manpage
      misc/ss: avoid NULL pointer dereference
      misc/ss: simplify buffer realloc, fix checking realloc failure
      misc/ss: add missing fclose() calls
      lib/namespace: don't leak fd in error case
      misc/ss: fix memory leak in user_ent_hash_build()
      lib/namespace: fix fd leakage in non-error case
      ip-address.8.in: fix BNF syntax error

Richard Alpe (1):
      tipc: fix bearer get/set help synopsis

Roopa Prabhu (3):
      mpls: always set type RTN_UNICAST and scope RT_SCOPE_UNIVERSE for
      support batching of ip route get commands
      bridge fdb: add 'use' option to set NTF_USE flag in fdb add reque=
sts

Stephen Hemminger (19):
      update kernel kernel headers from 3.19-rc
      update to lateset net-next headers
      update headers to 4.1-rc1 net-next
      Update kernels for net-next
      pkt_cls: update header
      configure: cleanup
      update to 4.2-pre-rc headers
      headers update
      update kernel headers for 4.2-rc1
      remove unnecessary checks for NULL before free
      ip: fix all the checkpatch warnings
      bridge: drop man page fragment
      ipnetns: make net namespace cache variable size
      remove unnecessary extern
      tc: fix return after invarg
      bond: fix return after invarg
      provide common json output formatter
      iplink: cleanup whitespace and checkpatch issues
      v4.2.0

Vadim Kochan (4):
      ss: fix crash when dump stats from /proc with '-p'
      man ss: Fix explanation when no options specified
      man ip-link: Add more explanation about vlan reordering
      man ip-link: Add little explanations about VLAN qos map

Zhang Shengju (10):
      xfrm: remove duplicated include
      ip/ip6tunnel: fix missing return value check
      iplink: add missing link type
      iplink: use the short format to print help info
      iplink: shortify printing the usage of link type
      ip-link: fix a typo in help message
      ip-link: enhance prompt message
      ip-link: remove unnecessary return
      utils: add missing return value
      ip-link: cut one level indentation
