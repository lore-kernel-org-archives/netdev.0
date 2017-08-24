From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v4 0/4] Covscan: Fix potential NULL pointer dereferences
Date: Thu, 24 Aug 2017 11:46:30 +0200
Message-ID: <20170824094634.4093-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:58875 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752435AbdHXJqx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 24 Aug 2017 05:46:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series collects patches from v1 which eliminate possible cases of
NULL pointer dereferences.

Changes since v3:
- Dropped upstream rejected patch 2.

Phil Sutter (4):
  ifstat, nstat: Check fdopen() return value
  tc/q_netem: Don't dereference possibly NULL pointer
  tc/tc_filter: Make sure filter name is not empty
  tipc/bearer: Prevent NULL pointer dereference

 misc/ifstat.c  | 16 +++++++++++-----
 misc/nstat.c   | 16 +++++++++++-----
 tc/q_netem.c   |  3 ++-
 tc/tc_filter.c |  3 +++
 tipc/bearer.c  |  2 +-
 5 files changed, 28 insertions(+), 12 deletions(-)

-- 
2.13.1
