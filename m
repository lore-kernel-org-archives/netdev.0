From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net-next] rtnetlink: bridge: use ext_ack instead of
 printk
Date: Tue, 10 Oct 2017 13:16:20 -0700 (PDT)
Message-ID: <20171010.131620.622870354908006725.davem@davemloft.net>
References: <20171010151004.20056-1-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dsahern@gmail.com
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53504 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934818AbdJJUQV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 16:16:21 -0400
In-Reply-To: <20171010151004.20056-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Tue, 10 Oct 2017 17:10:04 +0200

> We can now piggyback error strings to userspace via extended acks
> rather than using printk.
> 
> Before:
> bridge fdb add 01:02:03:04:05:06 dev br0 vlan 4095
> RTNETLINK answers: Invalid argument
> 
> After:
> bridge fdb add 01:02:03:04:05:06 dev br0 vlan 4095
> Error: invalid vlan id.
> 
> v3: drop 'RTM_' prefixes, suggested by David Ahern, they
> are not useful, the add/del in bridge command line is enough.
> 
> Also reword error in response to malformed/bad vlan id attribute
> size.
> 
> Cc: David Ahern <dsahern@gmail.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied, thanks.
