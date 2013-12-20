From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] ipv4: introduce ip_dst_mtu_secure and protect forwarding path against pmtu spoofing
Date: Fri, 20 Dec 2013 01:44:56 +0100
Message-ID: <20131220004456.GB32129@order.stressinduktion.org>
References: <20131219121757.GD14429@order.stressinduktion.org> <20131219.143012.205185984019527730.davem@davemloft.net> <20131219235338.GA32129@order.stressinduktion.org> <20131219.193321.590144194287655797.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: johnwheffner@gmail.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:41320 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753917Ab3LTAo5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 19:44:57 -0500
Content-Disposition: inline
In-Reply-To: <20131219.193321.590144194287655797.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 19, 2013 at 07:33:21PM -0500, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Fri, 20 Dec 2013 00:53:38 +0100
> 
> > I am fine dropping the knob and just unconditionally ignoring the
> > pmtu data in the forwarding path? Is that what you wanted to
> > suggest?
> 
> Quite the contrary, I thought it was clear that I want the default to
> be the current behavior.

Ok, sorry for misinterpretation.

I'll do so and will send the IPv6 one adopted as well, thanks!
