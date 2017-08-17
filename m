From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 0/5] Covscan: Fix potential NULL pointer dereferences
Date: Thu, 17 Aug 2017 19:09:26 +0200
Message-ID: <20170817170931.24545-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:41157 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753747AbdHQROT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Aug 2017 13:14:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series collects patches from v1 which eliminate possible cases of
NULL pointer dereferences.

No changes to the actual patches, just splitting into smaller series.

Phil Sutter (5):
  ifstat, nstat: Check fdopen() return value
  nstat: Fix for potential NULL pointer dereference
  tc/q_netem: Don't dereference possibly NULL pointer
  tc/tc_filter: Make sure filter name is not empty
  tipc/bearer: Prevent NULL pointer dereference

 misc/ifstat.c  | 16 +++++++++++-----
 misc/nstat.c   | 18 ++++++++++++------
 tc/q_netem.c   |  4 +++-
 tc/tc_filter.c |  3 +++
 tipc/bearer.c  |  4 ++--
 5 files changed, 31 insertions(+), 14 deletions(-)

-- 
2.13.1
