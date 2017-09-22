From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next v2 0/6] rtnetlink: preparation patches for further rtnl lock pushdown/removal
Date: Fri, 22 Sep 2017 08:10:02 +0200
Message-ID: <20170922061008.14723-1-fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:41574 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751795AbdIVGJu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2017 02:09:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First patch adds a rudimentary vrf test case.

Remaining patches split large rtnl_fill_ifinfo into smaller chunks
to better see which parts

1. require rtnl
2. do not require it at all
3. rely on rtnl locking now but could be converted

changes since v2:
- fix subject lines of patches 2 and 5
- drop pure ASSERT_RTNL annotation patch, its not all that useful
- remove two extra ASSERT_RTNL in last patch
