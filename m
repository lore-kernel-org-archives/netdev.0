From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v3 0/6] Covscan: Misc fixes
Date: Thu, 24 Aug 2017 11:41:25 +0200
Message-ID: <20170824094131.2963-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:53625 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752381AbdHXJmJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 24 Aug 2017 05:42:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series collects patches from v1 addressing miscellaneous issues
detected by covscan.

Changes since v2:
- Dropped patch 1 since v2 discussion is still inconclusive.
- Replaced patch 2 by a more appropriate one given feedback from v2.

Phil Sutter (6):
  ss: Make struct tcpstat fields 'timer' and 'timeout' unsigned
  ss: Make sure scanned index value to unix_state_map is sane
  netem/maketable: Check return value of fscanf()
  lib/bpf: Check return value of write()
  lib/fs: Fix and simplify make_path()
  lib/libnetlink: Don't pass NULL parameter to memcpy()

 lib/bpf.c         |  3 ++-
 lib/fs.c          | 20 +++++---------------
 lib/libnetlink.c  |  6 ++++--
 misc/ss.c         | 11 +++++------
 netem/maketable.c |  4 ++--
 5 files changed, 18 insertions(+), 26 deletions(-)

-- 
2.13.1
