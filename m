From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 0/2] Fix and enhance link_gre6
Date: Fri,  1 Sep 2017 16:08:07 +0200
Message-ID: <20170901140809.13230-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:50245 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752031AbdIAOI2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 1 Sep 2017 10:08:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changing a tunnel's flowlabel value was broken if it was set to a
non-zero value before. Since the same problem existed for tclass, patch
1 fixes both instances at once.

Patch 2 enhances 'ip link show' to also print the tclass value. This
change was necessary to properly test the first patch's result.

Phil Sutter (2):
  link_gre6: Fix for changing tclass/flowlabel
  link_gre6: Print the tunnel's tclass setting

 ip/link_gre6.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

-- 
2.13.1
