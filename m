From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference at 000000000000002c
Date: Thu, 02 Feb 2012 13:55:12 +0100
Message-ID: <4F2A87B0.6070900@profihost.ag>
References: <4F26E72E.2020007@profihost.ag>	<20120130.164828.1695146432151008554.davem@davemloft.net>	<4F27A18F.3060907@profihost.ag> <20120201.162157.880976652659067010.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: greg@kroah.com, eric.dumazet@gmail.com, jwboyer@gmail.com,
	hch@infradead.org, netdev@vger.kernel.org, david@fromorbit.com,
	stable@vger.kernel.org, gregkh@suse.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.profihost.ag ([85.158.179.208]:56598 "EHLO
	mail.profihost.ag" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753254Ab2BBMyz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2012 07:54:55 -0500
In-Reply-To: <20120201.162157.880976652659067010.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Such a non-trivial backport has the danger of adding as many bugs as
> it is intended to fix.
> 
> Therefore I will not be attempting to make this fix feasible for
> 3.0.x-stable, sorry.
> 
> I seriously suggest that if you really are hitting this race (the
> exposure is very small, it only happens if you get redirects and
> redirects are not common for most hosts) that you move to a more
> recent kernel such as 3.1.x or 3.2.x, both of which have all the
> dependencies as well as the bug fix applied.

I fully understand that - i'm seeing this bug 2-3 times a week while
running a bunch of > 1000 servers.

I don't want to go to 3.1 or 3.2 as they're not long term.

So i'll try to make own backport. First steps done and seems to work
fine. Sadly i'm not a C programmer...

Greets

Stefan
