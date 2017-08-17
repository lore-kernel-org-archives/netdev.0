From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 0/3] Covscan: Fixes for obvious programming mistakes
Date: Thu, 17 Aug 2017 19:09:29 +0200
Message-ID: <20170817170932.24812-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:53023 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753255AbdHQRMj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Aug 2017 13:12:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series collects those patches from v1 which are clear programming
flaws.

No changes to the actual patches, just splitting into smaller series.

Phil Sutter (3):
  iproute_lwtunnel: csum_mode value checking was ineffective
  iproute_lwtunnel: Argument to strerror must be positive
  tipc/node: Fix socket fd check in cmd_node_get_addr()

 ip/iproute_lwtunnel.c | 9 +++++----
 tipc/node.c           | 3 ++-
 2 files changed, 7 insertions(+), 5 deletions(-)

-- 
2.13.1
