From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC PATCH net-next V2] net: split rt_genid for ipv4 and ipv6
Date: Tue, 23 Jul 2013 04:04:37 +0200
Message-ID: <20130723020437.GC30719@order.stressinduktion.org>
References: <1374543420-12657-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net, nicolas.dichtel@6wind.com,
	yoshfuji@linux-ipv6.org, jmorris@namei.org,
	steffen.klassert@secunet.com, netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:33286 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750872Ab3GWCEi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jul 2013 22:04:38 -0400
Content-Disposition: inline
In-Reply-To: <1374543420-12657-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 23, 2013 at 09:37:00AM +0800, Fan Du wrote:
> Current net name space has only one genid for both IPv4 and IPv6, it has below drawbacks:
> 
> - Add/delete an IPv4 address will invalidate all IPv6 routing table entries.
> - Insert/remove XFRM policy will also invalidate both IPv4/IPv6 routing table entries
>   even when the policy is only applied for one address family.
> 
> Thus, this patch attempt to split one genid for two to cater for IPv4 and IPv6 separately
> in a fine granularity.

For me the approach seems reasonable. We should double-check if this
does not affect v4mapped af_inet6 sockets in any way. I could help to
do the review if there is an agreement that the split is desirable.

Thanks,

  Hannes
