From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] inet: make RTM_GETROUTE work without rtnl
Date: Tue, 15 Aug 2017 17:21:10 -0700 (PDT)
Message-ID: <20170815.172110.1790071539239773128.davem@davemloft.net>
References: <20170815143444.17002-1-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44172 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752401AbdHPAVL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 20:21:11 -0400
In-Reply-To: <20170815143444.17002-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Tue, 15 Aug 2017 16:34:40 +0200

> ipv4 getroute doesn't assume rtnl lock is held anymore, also make
> this true for ipv6, then switch both to DOIT_UNLOCKED.

Series applied, thanks Florian.
