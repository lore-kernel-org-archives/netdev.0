From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 0/2] Covscan: Fix potential file descriptor leaks
Date: Thu, 17 Aug 2017 19:09:29 +0200
Message-ID: <20170817170931.24224-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:54673 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752031AbdHQRJn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Aug 2017 13:09:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series collects patches from v1 which deal with potential file
descriptor leaks.

No changes to the actual patches, just splitting into smaller series.

Phil Sutter (2):
  ss: Don't leak fd in tcp_show_netlink_file()
  tc/em_ipset: Don't leak sockfd on error path

 misc/ss.c     | 32 ++++++++++++++++++++------------
 tc/em_ipset.c |  1 +
 2 files changed, 21 insertions(+), 12 deletions(-)

-- 
2.13.1
