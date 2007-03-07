From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] Improve cached ECMP documentation
Date: Wed, 7 Mar 2007 14:54:15 +0100
Message-ID: <20070307135415.GB2268@ff.dom.local>
References: <20070307073932.GA1675@ff.dom.local> <45EEB218.8000804@linpro.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S\. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Tore Anderson <tore@linpro.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:57935 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S965336AbXCGNuS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Mar 2007 08:50:18 -0500
Content-Disposition: inline
In-Reply-To: <45EEB218.8000804@linpro.no>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 07, 2007 at 01:37:44PM +0100, Tore Anderson wrote:
> Document that equal-cost multipath routing with caching does not work
> for forwarded packets.
> 
> Signed-Off-By: Tore Anderson <tore@linpro.no>
> ---
> 
> * Jarek Poplawski
> 
> >It is probably one of the most often asked questions
> >on the LARTC, so I'd suggest to look at its archives.
> >
> >[...]
> >
> >Multipath with caching doesn't work with forwarding.
> 
>  Well, I did look at LARTC's archives (and again after reading your
> mail), still couldn't find anything.  Sorry for bothering you, though.

I don't feel bothered at all. Your letter could
make an impression there is a lack of help and
google not working, but it's not always true. 
So, sometimes people probably wait to see, they
will only help and not do all your work. 

> When I disabled the support it worked just fine (no need for iptables
> CONNMARK trickery or any of Julian's patches), so thanks for your help!

Without this there is a possibility the route could be
changed during connection.

>  Anyway, it strikes me as a bit odd that this feature is found under
> CONFIG_IP_ADVANCED_ROUTER when it doesn't work for routers.  That
> could at least be better documented - here's a patch to do just that.

Maybe it's intended for something even more advanced,
I don't know. I checked this long time ago and later
seen someone was trying to fix something around this
- so I don't know what is the current state. But you
are right - this should be better documented.

Cheers,
Jarek P.
