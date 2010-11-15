From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] tcp: restrict net.ipv4.tcp_adv_min_scale (#20312)
Date: Mon, 15 Nov 2010 14:18:42 +0000
Message-ID: <1289830722.2586.5.camel@bwh-desktop>
References: <20101114151825.GA25137@core2.telecom.by>
	 <1289764183.2743.94.camel@edumazet-laptop>
	 <20101114201458.GA28181@core2.telecom.by>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
	shemminger@linux-foundation.org, netdev@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:13767 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755593Ab0KOOSp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Nov 2010 09:18:45 -0500
In-Reply-To: <20101114201458.GA28181@core2.telecom.by>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2010-11-14 at 22:14 +0200, Alexey Dobriyan wrote:
> On Sun, Nov 14, 2010 at 08:49:43PM +0100, Eric Dumazet wrote:
> > > +static int _minus_31 = -31;
> > > +static int _31 = 31;
> > 
> > Please use normal symbols, not starting by underscore.
> 
> static int thirty_one = 31? :-)

How about, oh, I don't know, adv_win_scale_{min,max}?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

