From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 0/3] Check user supplied interface name lengths
Date: Tue, 26 Sep 2017 18:35:45 +0200
Message-ID: <20170926163548.24347-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:58118 "EHLO orbyte.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S968971AbdIZQgQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 26 Sep 2017 12:36:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds explicit checks for user-supplied interface names to
make sure their length fits Linux's requirements.

The first two patches simplify interface name parsing in some places -
these are side-effects of working on the actual implementation provided
in patch three.

Changes since v1:
- Patches 1 and 2 introduced.
- Changes to patch 3 are listed in there.

Phil Sutter (3):
  ip{6,}tunnel: Avoid copying user-supplied interface name around
  tc: flower: No need to cache indev arg
  Check user supplied interface name lengths

 include/utils.h |  1 +
 ip/ip6tunnel.c  |  9 +++++----
 ip/ipl2tp.c     |  3 ++-
 ip/iplink.c     | 27 ++++++++-------------------
 ip/ipmaddr.c    |  1 +
 ip/iprule.c     |  4 ++++
 ip/iptunnel.c   | 27 +++++++++++++--------------
 ip/iptuntap.c   |  4 +++-
 lib/utils.c     | 10 ++++++++++
 misc/arpd.c     |  1 +
 tc/f_flower.c   |  6 ++----
 11 files changed, 50 insertions(+), 43 deletions(-)

-- 
2.13.1
