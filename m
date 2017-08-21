From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v3 0/5] Covscan: Fix potential NULL pointer dereferences
Date: Mon, 21 Aug 2017 12:03:03 +0200
Message-ID: <20170821100308.24854-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:51869 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751821AbdHUKDj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Aug 2017 06:03:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series collects patches from v1 which eliminate possible cases of
NULL pointer dereferences.

Changes since v2:
- Rebased onto current master branch.
- Adjusted patches according to feedback.

Phil Sutter (5):
  ifstat, nstat: Check fdopen() return value
  nstat: Fix for potential NULL pointer dereference
  tc/q_netem: Don't dereference possibly NULL pointer
  tc/tc_filter: Make sure filter name is not empty
  tipc/bearer: Prevent NULL pointer dereference

 misc/ifstat.c  | 16 +++++++++++-----
 misc/nstat.c   | 18 +++++++++++++-----
 tc/q_netem.c   |  3 ++-
 tc/tc_filter.c |  3 +++
 tipc/bearer.c  |  2 +-
 5 files changed, 30 insertions(+), 12 deletions(-)

-- 
2.13.1
