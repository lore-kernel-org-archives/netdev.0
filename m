From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 0/4] Smaller link type help review
Date: Tue, 28 Mar 2017 23:19:35 +0200
Message-ID: <20170328211939.17922-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:40889 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752931AbdC1VUO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 28 Mar 2017 17:20:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series addresses some minor nits with link type specific help
texts:

* Unify coding style of print_help() callbacks (or the functions they
  call.

* Unify output as much as possible for a common look and feel.

* Make sure there's type specific help for each type listed in 'ip link
  help'.

Phil Sutter (4):
  ip: link: bond: Fix whitespace in help text
  ip: link: macvlan: Add newline to help output
  ip: link: Unify link type help functions a bit
  ip: link: Add missing link type help texts

 ip/Makefile         |  3 ++-
 ip/iplink_bond.c    |  2 +-
 ip/iplink_dummy.c   | 16 ++++++++++++++++
 ip/iplink_geneve.c  | 28 ++++++++++++++++++----------
 ip/iplink_ifb.c     | 16 ++++++++++++++++
 ip/iplink_ipoib.c   |  4 +++-
 ip/iplink_macvlan.c |  1 +
 ip/iplink_nlmon.c   | 16 ++++++++++++++++
 ip/iplink_team.c    | 25 +++++++++++++++++++++++++
 ip/iplink_vcan.c    | 16 ++++++++++++++++
 ip/iplink_vlan.c    | 15 +++++++++------
 ip/iplink_vxlan.c   | 44 +++++++++++++++++++++++++++++---------------
 ip/link_gre.c       | 36 +++++++++++++++++++++++-------------
 ip/link_gre6.c      | 47 ++++++++++++++++++++++++++++-------------------
 ip/link_ip6tnl.c    | 46 +++++++++++++++++++++++++++-------------------
 ip/link_iptnl.c     | 38 ++++++++++++++++++++++++++------------
 ip/link_vti.c       | 17 +++++++++--------
 17 files changed, 265 insertions(+), 105 deletions(-)
 create mode 100644 ip/iplink_dummy.c
 create mode 100644 ip/iplink_ifb.c
 create mode 100644 ip/iplink_nlmon.c
 create mode 100644 ip/iplink_team.c
 create mode 100644 ip/iplink_vcan.c

-- 
2.11.0
