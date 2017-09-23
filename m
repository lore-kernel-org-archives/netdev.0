From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next v3 0/6] rtnetlink: preparation patches for further rtnl lock pushdown/removal
Date: Sat, 23 Sep 2017 21:26:30 +0200
Message-ID: <20170923192636.3932-1-fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:46810 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751030AbdIWT0T (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 23 Sep 2017 15:26:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First patch adds a rudimentary vrf test case.

Remaining patches split large rtnl_fill_ifinfo into smaller chunks
to better see which parts

1. require rtnl
2. do not require it at all
3. rely on rtnl locking now but could be converted

I removed all the ASSERT_RTNL spots that v1 and v2 added,
i will keep that back in my working branch since those
are just 'todo' markers for myself.

Eric Dumazet pointed out that qdiscs are now freed directly without
call_rcu so I dropped the patch that made this assumption from the series.

As the remaining patches did not see major changes vs. v2 I retained
all reviewed/acked-by tags from David Ahern.
