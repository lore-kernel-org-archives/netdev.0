From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH RFC 0/5] netfilter: implement netfilter SYN proxy
Date: Thu, 8 Aug 2013 02:04:12 +0200
Message-ID: <20130808000412.GF32257@order.stressinduktion.org>
References: <1375898766.4004.37.camel@edumazet-glaptop> <20130807205959.GC21463@macbook.localnet> <20130807210540.GE32257@order.stressinduktion.org> <20130807.164056.2110811182336568861.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: kaber@trash.net, eric.dumazet@gmail.com, pablo@netfilter.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	mph@one.com, jesper.brouer@gmail.com, as@one.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:38244 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933310Ab3HHAEO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Aug 2013 20:04:14 -0400
Content-Disposition: inline
In-Reply-To: <20130807.164056.2110811182336568861.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 07, 2013 at 04:40:56PM -0700, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Wed, 7 Aug 2013 23:05:40 +0200
> 
> > It seems, Windows stopped using tcp timestamps at least in windows 8 by
> > default.
> 
> Thankfully, Android device outnumber Windows 8 installs
> by... something like 1,000 to 1, right?

Heh, at minimum. :)

> I throw a huge "doesn't matter" to whatever Windows's TCP stack
> decides to do.  It absolutely should not dictate whether we decide to
> make use of this or that feature of TCP.  It's a bit player at best.
> 
> So if Windows 8 is the reason you're saying we shouldn't use
> timestamps for anything, you're wrong.

Actually, I don't care at all, because I don't do anything with windows
and don't get paid by anyone who wants me to care. ;)

But if we switch to a similar scheme as freebsd we can even care
less because even if some other operating systems or a major provider
decides to disable timestamps on their devices, we would still have
window scaling, sack (and ecn?) under syn dos. So, I do think it is an
improvement and don't see any disadvantages.

So, I don't care as long as the change (and siphash or maybe another
hashing scheme) is secure enough...

Greetings,

  Hannes
