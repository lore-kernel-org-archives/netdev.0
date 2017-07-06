From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: ipv6: Compare lwstate in detecting duplicate
 nexthops
Date: Thu, 06 Jul 2017 10:49:10 +0100 (WEST)
Message-ID: <20170706.104910.1712476410202706181.davem@davemloft.net>
References: <20170705204146.5263-1-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, buytenh@wantstofly.org,
        roopa@cumulusnetworks.com, rshearma@brocade.com
To: dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57082 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752000AbdGFJtN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Jul 2017 05:49:13 -0400
In-Reply-To: <20170705204146.5263-1-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsahern@gmail.com>
Date: Wed,  5 Jul 2017 14:41:46 -0600

> Lennert reported a failure to add different mpls encaps in a multipath
> route:
> 
>   $ ip -6 route add 1234::/16 \
>         nexthop encap mpls 10 via fe80::1 dev ens3 \
>         nexthop encap mpls 20 via fe80::1 dev ens3
>   RTNETLINK answers: File exists
> 
> The problem is that the duplicate nexthop detection does not compare
> lwtunnel configuration. Add it.
> 
> Fixes: 19e42e451506("ipv6: support for fib route lwtunnel encap attributes")
> Signed-off-by: David Ahern <dsahern@gmail.com>

Applied and queued up for -stable, thanks.
