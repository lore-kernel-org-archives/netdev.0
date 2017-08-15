From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 0/4] inet: make RTM_GETROUTE work without rtnl
Date: Tue, 15 Aug 2017 16:34:40 +0200
Message-ID: <20170815143444.17002-1-fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:41022 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752335AbdHOOe0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 10:34:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ipv4 getroute doesn't assume rtnl lock is held anymore, also make
this true for ipv6, then switch both to DOIT_UNLOCKED.
