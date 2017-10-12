From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] ipv6: addrconf: don't use rtnl mutex in
 RTM_GETNETCONF
Date: Wed, 11 Oct 2017 20:17:20 -0700 (PDT)
Message-ID: <20171011.201720.1814836553811001805.davem@davemloft.net>
References: <20171011082801.12715-1-fw@strlen.de>
        <20171011082801.12715-2-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42020 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752468AbdJLDRV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 23:17:21 -0400
In-Reply-To: <20171011082801.12715-2-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Wed, 11 Oct 2017 10:28:00 +0200

> Instead of relying on rtnl mutex bump device reference count.
> After this change, values reported can change in parallel, but thats not
> much different from current state, as anyone can change the settings
> right after rtnl_unlock (and before userspace processed reply).
> 
> While at it, switch to GFP_KERNEL allocation.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied.
