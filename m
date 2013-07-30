From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v4] net: split rt_genid for ipv4 and ipv6
Date: Tue, 30 Jul 2013 09:07:02 +0200
Message-ID: <20130730070702.GG2490@order.stressinduktion.org>
References: <1375144433-731-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net, nicolas.dichtel@6wind.com,
	yoshfuji@linux-ipv6.org, jmorris@namei.org,
	steffen.klassert@secunet.com, paul@paul-moore.com,
	netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:47740 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753194Ab3G3HHE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jul 2013 03:07:04 -0400
Content-Disposition: inline
In-Reply-To: <1375144433-731-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 30, 2013 at 08:33:53AM +0800, Fan Du wrote:
> Current net name space has only one genid for both IPv4 and IPv6, it has below
> drawbacks:
> 
> - Add/delete an IPv4 address will invalidate all IPv6 routing table entries.
> - Insert/remove XFRM policy will also invalidate both IPv4/IPv6 routing table
>   entries even when the policy is only applied for one address family.
> 
> Thus, this patch attempt to split one genid for two to cater for IPv4 and IPv6
> separately in a fine granularity.
> 
> Signed-off-by: Fan Du <fan.du@windriver.com>

Also this patch only applies with some fuzz, it addressed all my issues:

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks,

  Hannes
