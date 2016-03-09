From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [RFC] net: ipv4 -- Introduce ifa limit per net
Date: Wed, 9 Mar 2016 20:53:07 +0300
Message-ID: <20160309175307.GM2207@uranus.lan>
References: <20160309163919.GJ2207@uranus.lan>
 <20160309165850.GA49579@ast-mbp.thefacebook.com>
 <20160309170921.GL2207@uranus.lan>
 <20160309.122400.951958972682394628.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexei.starovoitov@gmail.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, solar@openwall.com, vvs@virtuozzo.com,
	avagin@virtuozzo.com, xemul@virtuozzo.com, vdavydov@virtuozzo.com,
	khorenko@virtuozzo.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:35165 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933744AbcCIRxW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 12:53:22 -0500
Received: by mail-lb0-f171.google.com with SMTP id bc4so76480278lbc.2
        for <netdev@vger.kernel.org>; Wed, 09 Mar 2016 09:53:21 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20160309.122400.951958972682394628.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 09, 2016 at 12:24:00PM -0500, David Miller wrote:
...
> We asked you for numbers without a lot of features enabled, it'll
> help us diagnose which subsystem still causes a lot of overhead
> much more clearly.
> 
> So please do so.

Sure. Gimme some time and I'll back with numbers.

> Although it's already pretty clear that netfilter conntrack
> cleanup is insanely expensive.

Yes. I can drop it off for a while and run tests without it,
then turn it back and try again. Would you like to see such
numbers?

> You're also jumping to a lot of conclusions, work with us to fix the
> fundamental performance problems rather than continually insisting on
> a limit.
> 
> We should be able to remove millions of IP addresses in less than
> half a second, no problem.  Limits make no sense at all.

Sure, I'll continue experimenting (and turn off preemt as
a first step). Sorry if I sounded rough.

	Cyrill
