From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 0/3] Covscan: Fix for missing error checking
Date: Mon, 21 Aug 2017 18:36:49 +0200
Message-ID: <20170821163652.23752-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:35941 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753726AbdHUQhK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Aug 2017 12:37:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series collects patches from v1 dealing with spots where error
checking is necessary or recommended.

Minor changes to patches 1 and 2, patch 3 remains unchanged.

Phil Sutter (3):
  iproute: Check mark value input
  iplink_vrf: Complain if main table is not found
  devlink: Check return code of strslashrsplit()

 devlink/devlink.c | 16 ++++++++++++----
 ip/iplink_vrf.c   |  4 +++-
 ip/iproute.c      |  6 ++++--
 3 files changed, 19 insertions(+), 7 deletions(-)

-- 
2.13.1
