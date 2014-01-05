From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 1/2] ipv4: add forwarding_uses_pmtu knob to protect forward path to use pmtu info
Date: Sun, 5 Jan 2014 11:41:09 +0100
Message-ID: <20140105104109.GE25828@order.stressinduktion.org>
References: <20131220130822.GD32129@order.stressinduktion.org> <20131230.222044.884570280065942449.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	steffen.klassert@secunet.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:39910 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750992AbaAEKlL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jan 2014 05:41:11 -0500
Content-Disposition: inline
In-Reply-To: <20131230.222044.884570280065942449.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David!

On Mon, Dec 30, 2013 at 10:20:44PM -0500, David Miller wrote:
> The only thing left are things like AH and ESP, which also perform
> some level of validation making sure that some state exists.  And
> frankly for non-tunneled IPSEC this PMTU information is absolutely
> essential.

I am trying to finish the testing of these patches with ipsec.

What do you mean here by non-tunneled IPSEC? Transport mode is not an issue
with this patch as we don't push packets for transport mode through
forwarding. Tunneled mode would invoke fragmentation again. It is always
ensured that mtu in ip_forward is higher than when xfrm layer checks with
dst_mtu, so nothing should break here.

Thank you,

  Hannes
