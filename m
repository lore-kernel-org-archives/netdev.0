From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: namespace cleanups
Date: Wed, 01 Jan 2014 23:46:42 -0500 (EST)
Message-ID: <20140101.234642.69383936858368776.davem@davemloft.net>
References: <20131229140331.2bccc424@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46489 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751233AbaABEqn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jan 2014 23:46:43 -0500
In-Reply-To: <20131229140331.2bccc424@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Sun, 29 Dec 2013 14:03:31 -0800

> Running 'make namespacecheck' shows:
>   net/ipv6/route.o
>     ipv6_route_table_template
>     rt6_bind_peer
>   net/ipv6/icmp.o
>     icmpv6_route_lookup
>     ipv6_icmp_table_template
> 
> This addresses some of those warnings by:
>  * make icmpv6_route_lookup static
>  * move inline's out of ip6_route.h since only used into route.c
>  * move rt6_bind_peer into route.c
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied.
