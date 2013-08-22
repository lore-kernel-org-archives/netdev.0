From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Problematic commits in the ipsec tree
Date: Thu, 22 Aug 2013 13:21:04 +0200
Message-ID: <20130822112104.GB19269@order.stressinduktion.org>
References: <20130822104724.GD26773@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:39447 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752534Ab3HVLVH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 07:21:07 -0400
Content-Disposition: inline
In-Reply-To: <20130822104724.GD26773@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 22, 2013 at 12:47:24PM +0200, Steffen Klassert wrote:
> I have two problematic commits from you in the ipsec tree. The first one is:
> 
> commit 0ea9d5e3e (xfrm: introduce helper for safe determination of mtu)
> 
> This breakes pmtu discovery for IPv4 because now we use the device mtu
> instead of the reduced IPsec mtu in xfrm4_tunnel_check_size() if a IPv4
> socket is at the skb.
> 
> The second is:
> 
> commit 844d48746 (xfrm: choose protocol family by skb protocol)
> 
> This breaks pmtu discovery for IPv6 too because skb->protocol can be null
> in __xfrm6_output().
> 
> We need a solution soon, or I have to revert or remove these commits from
> the ipsec tree.

Thanks for letting me know. I'll work on it right away.
