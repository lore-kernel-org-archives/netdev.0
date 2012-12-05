From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ICMPv6 packets transmitted on wrong interface if
 nfmark is mangled
Date: Wed, 05 Dec 2012 12:57:00 -0500 (EST)
Message-ID: <20121205.125700.2246243377198648534.davem@davemloft.net>
References: <CA+e04fjWMDE9xEApysFRprZDBdM3Ya2RHrxtoau7i+fxzGT8CQ@mail.gmail.com>
	<20121203.170636.1325623456787407245.davem@davemloft.net>
	<CA+e04fgiMDoaCx0fpdK5F6YfJ_CSOZ13q1fn9xs7De4JO02c6g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, kaber@trash.net, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: dries.dewinter@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35443 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751599Ab2LER5C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2012 12:57:02 -0500
In-Reply-To: <CA+e04fgiMDoaCx0fpdK5F6YfJ_CSOZ13q1fn9xs7De4JO02c6g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dries De Winter <dries.dewinter@gmail.com>
Date: Wed, 5 Dec 2012 14:41:59 +0100

> My "noreroute" patch will not fix this. Therefore it's indeed maybe
> better to add a simple check to ip6_route_me_harder(): not a check for
> ICMPv6, but a check for (ipv6_addr_type(&iph->daddr) &
> IPV6_ADDR_LINKLOCAL) instead. What do you think?

What if a packet is rewritten from a non-link-local destination address
into a link-local one?  Or vice versa?

Your test will fail in those cases.
