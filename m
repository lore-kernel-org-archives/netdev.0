From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] ipv6: Allow IPv4-mapped address as next-hop
Date: Mon, 05 Dec 2016 14:52:23 -0500 (EST)
Message-ID: <20161205.145223.1574324293082144579.davem@davemloft.net>
References: <1480827429-22259-1-git-send-email-nordmark@arista.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gilligan@arista.com
To: nordmark@arista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49216 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751373AbcLETwZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 14:52:25 -0500
In-Reply-To: <1480827429-22259-1-git-send-email-nordmark@arista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Nordmark <nordmark@arista.com>
Date: Sat,  3 Dec 2016 20:57:09 -0800

> Made kernel accept IPv6 routes with IPv4-mapped address as next-hop.
> 
> It is possible to configure IP interfaces with IPv4-mapped addresses, and
> one can add IPv6 routes for IPv4-mapped destinations/prefixes, yet prior
> to this fix the kernel returned an EINVAL when attempting to add an IPv6
> route with an IPv4-mapped address as a nexthop/gateway.
> 
> RFC 4798 (a proposed standard RFC) uses IPv4-mapped addresses as nexthops,
> thus in order to support that type of address configuration the kernel
> needs to allow IPv4-mapped addresses as nexthops.
> 
> Signed-off-by: Erik Nordmark <nordmark@arista.com>
> Signed-off-by: Bob Gilligan <gilligan@arista.com>

Applied to net-next, thanks.
