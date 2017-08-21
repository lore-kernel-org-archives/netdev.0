From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 0/7] Covscan: Misc fixes
Date: Mon, 21 Aug 2017 19:08:06 +0200
Message-ID: <20170821170813.29697-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:50355 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753961AbdHURJJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Aug 2017 13:09:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series collects patches from v1 addressing miscellaneous issues
detected by covscan.

No changes to the actual patches, just splitting into smaller series.

Phil Sutter (7):
  nstat: Avoid passing negative fd to fdopen()
  ss: Make sure index variable is >= 0
  ss: Make sure scanned index value to unix_state_map is sane
  netem/maketable: Check return value of fscanf()
  lib/bpf: Check return value of write()
  lib/fs: Fix and simplify make_path()
  lib/libnetlink: Don't pass NULL parameter to memcpy()

 lib/bpf.c         |  3 ++-
 lib/fs.c          | 20 +++++---------------
 lib/libnetlink.c  |  6 ++++--
 misc/nstat.c      | 15 +++++++++++----
 misc/ss.c         |  5 +++--
 netem/maketable.c |  4 ++--
 6 files changed, 27 insertions(+), 26 deletions(-)

-- 
2.13.1
