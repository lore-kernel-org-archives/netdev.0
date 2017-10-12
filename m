From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] ipv6: addrconf: don't use rtnl mutex in
 RTM_GETADDR
Date: Wed, 11 Oct 2017 20:17:25 -0700 (PDT)
Message-ID: <20171011.201725.646380607630686644.davem@davemloft.net>
References: <20171011082801.12715-1-fw@strlen.de>
        <20171011082801.12715-3-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42028 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752636AbdJLDR0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 23:17:26 -0400
In-Reply-To: <20171011082801.12715-3-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Wed, 11 Oct 2017 10:28:01 +0200

> Similar to the previous patch, use the device lookup functions
> that bump device refcount and flag this as DOIT_UNLOCKED to avoid
> rtnl mutex.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied.
