From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/7] rtnetlink: allow to run selected handlers
 without rtnl
Date: Wed, 09 Aug 2017 09:42:23 -0700 (PDT)
Message-ID: <20170809.094223.2075150457804233636.davem@davemloft.net>
References: <20170808.213329.522107918983433411.davem@davemloft.net>
        <20170809081928.GA26899@breakpoint.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41894 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752187AbdHIQmX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 12:42:23 -0400
In-Reply-To: <20170809081928.GA26899@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Wed, 9 Aug 2017 10:19:28 +0200

> Would you accept a v2 if i don't touch ipv6 routes for the time being?
> 
> I would then audit those again.  At the very least inet6_rtm_getroute should
> be able to work without rtnl lock (i.e., use a different lock if
> needed to protect vs. concurrent modifications).

Generally speaking 'get' operations should be fine.
