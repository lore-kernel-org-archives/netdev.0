From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 0/6] rtnetlink: fix initial rtnl pushdown fallout
Date: Thu, 10 Aug 2017 16:52:56 +0200
Message-ID: <20170810145302.30391-1-fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:46618 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752091AbdHJOwp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 10:52:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series fixes various bugs and splats reported since the
allow-handler-to-run-with-no-rtnl series went in.

Last patch adds a script that can be used to add further
tests in case more bugs are reported.
In case you prefer reverting the original series instead of
fixing fallout I can resend this patch on its own.
