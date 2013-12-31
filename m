From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] ipv4: introduce hardened ip_no_pmtu_disc mode
Date: Tue, 31 Dec 2013 06:44:30 +0100
Message-ID: <20131231054430.GD27636@order.stressinduktion.org>
References: <20131221001054.GD14073@order.stressinduktion.org> <20131231.003711.245680762305512090.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:59908 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750746Ab3LaFoc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Dec 2013 00:44:32 -0500
Content-Disposition: inline
In-Reply-To: <20131231.003711.245680762305512090.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 31, 2013 at 12:37:11AM -0500, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Sat, 21 Dec 2013 01:10:54 +0100
> 
> > This new ip_no_pmtu_disc mode only allowes fragmentation-needed errors
> > to be honored by protocols which do more stringent validation on the
> > ICMP's packet payload. This knob is useful for people who e.g. want to
> > run an unmodified DNS server in a namespace where they need to use pmtu
> > for TCP connections (as they are used for zone transfers or fallback
> > for requests) but don't want to use possibly spoofed UDP pmtu information.
> > 
> > Currently the whitelisted protocols are TCP, SCTP and DCCP as they check
> > if the returned packet is in the window or if the association is valid.
> > 
> > Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> 
> I think this is going to have the same problem as the forwarding
> sysctl, someone is going to convince some distribution to turn this
> thing to the new "3" hardened mode by default.
> 
> I'm not applying this... for now, sorry.

Ok, I see your concerns. I really intended its use just for a namespace
sealing off a name server.

Should I make this mode unavailable in init_net? ;)
(maybe, seriously?)

Thanks!
