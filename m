From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 0/5] Covscan: Fix potential memory leaks
Date: Thu, 17 Aug 2017 19:09:26 +0200
Message-ID: <20170817170931.24435-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:33027 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753540AbdHQRN3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Aug 2017 13:13:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series collects patches from v1 which deal with potential memory leaks.

No changes to the actual patches, just splitting into smaller series.

Phil Sutter (5):
  ipvrf: Fix error path of vrf_switch()
  ifstat: Fix memleak in error case
  ifstat: Fix memleak in dump_kern_db() for json output
  ss: Fix potential memleak in unix_stats_print()
  tipc/bearer: Fix resource leak in error path

 ip/ipvrf.c    |  9 +++++----
 misc/ifstat.c | 12 +++++++++---
 misc/ss.c     |  4 +++-
 tipc/bearer.c |  3 +++
 4 files changed, 20 insertions(+), 8 deletions(-)

-- 
2.13.1
