From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 0/7] Covscan: Dead code elimination
Date: Thu, 17 Aug 2017 19:09:24 +0200
Message-ID: <20170817170931.24089-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:41767 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753667AbdHQROB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Aug 2017 13:14:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series collects patches from v1 which deal with dead code, either
by removing it or changing context so it is accessed again if that makes
sense.

No changes to the actual patches, just splitting into smaller series.

Phil Sutter (7):
  devlink: No need for this self-assignment
  ipntable: No need to check and assign to parms_rta
  iproute: Fix for missing 'Oifs:' display
  lib/rt_names: Drop dead code in rtnl_rttable_n2a()
  ss: Skip useless check in parse_hostcond()
  ss: Drop useless assignment
  tc/m_gact: Drop dead code

 devlink/devlink.c |  2 +-
 ip/ipntable.c     |  2 --
 ip/iproute.c      |  8 +++++---
 lib/rt_names.c    |  4 ----
 misc/ss.c         |  3 +--
 tc/m_gact.c       | 14 +++-----------
 6 files changed, 10 insertions(+), 23 deletions(-)

-- 
2.13.1
