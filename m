From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] net: core: rcuify rtnl af_ops
Date: Mon, 16 Oct 2017 21:26:56 +0100 (WEST)
Message-ID: <20171016.212656.1943805874831429952.davem@davemloft.net>
References: <20171016134436.25282-1-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34782 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754027AbdJPU06 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 16:26:58 -0400
In-Reply-To: <20171016134436.25282-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Mon, 16 Oct 2017 15:44:34 +0200

> None of the rtnl af_ops callbacks sleep, so they can be called while
> holding rcu read lock.
> 
> Switch handling of af_ops to rcu.
> 
> This would allow to later call af_ops functions without holding
> the rtnl mutex anymore.

Series applied, thanks.
