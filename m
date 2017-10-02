From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v3 0/3] Check user supplied interface name lengths
Date: Mon,  2 Oct 2017 13:46:34 +0200
Message-ID: <20171002114637.25703-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:46120 "EHLO orbyte.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750957AbdJBLrE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 2 Oct 2017 07:47:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds explicit checks for user-supplied interface names to
make sure they fit Linux's requirements.

The first two patches simplify interface name parsing in some places -
these are side-effects of working on the actual implementation provided
in patch three.

Changes since v2:
- Changed patch 3 as suggested in review.

Changes since v1:
- Patches 1 and 2 introduced.
- Changes to patch 3 are listed in there.

Phil Sutter (3):
  ip{6,}tunnel: Avoid copying user-supplied interface name around
  tc: flower: No need to cache indev arg
  Check user supplied interface name lengths

 include/utils.h |  2 ++
 ip/ip6tunnel.c  |  9 +++++----
 ip/ipl2tp.c     |  4 +++-
 ip/iplink.c     | 31 ++++++++++++-------------------
 ip/ipmaddr.c    |  3 ++-
 ip/iprule.c     | 10 ++++++++--
 ip/iptunnel.c   | 29 +++++++++++++++--------------
 ip/iptuntap.c   |  6 ++++--
 lib/utils.c     | 29 +++++++++++++++++++++++++++++
 misc/arpd.c     |  3 ++-
 tc/f_flower.c   |  7 +++----
 11 files changed, 85 insertions(+), 48 deletions(-)

-- 
2.13.1
