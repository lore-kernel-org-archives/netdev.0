From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH RFC 0/5] netfilter: implement netfilter SYN proxy
Date: Wed, 7 Aug 2013 23:24:10 +0200
Message-ID: <20130807212410.GA22932@macbook.localnet>
References: <1375897371-18430-1-git-send-email-kaber@trash.net>
 <1375898766.4004.37.camel@edumazet-glaptop>
 <20130807205959.GC21463@macbook.localnet>
 <20130807210540.GE32257@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Eric Dumazet <eric.dumazet@gmail.com>, pablo@netfilter.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	mph@one.com, jesper.brouer@gmail.com, as@one.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48741 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933311Ab3HGVYO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Aug 2013 17:24:14 -0400
Content-Disposition: inline
In-Reply-To: <20130807210540.GE32257@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 07, 2013 at 11:05:40PM +0200, Hannes Frederic Sowa wrote:
> On Wed, Aug 07, 2013 at 10:59:59PM +0200, Patrick McHardy wrote:
> > On Wed, Aug 07, 2013 at 11:06:06AM -0700, Eric Dumazet wrote:
> > > TCP timestamps are not really used, for various reasons ...
> > > 
> > > Have you taken a look at 
> > > 
> > > <http://lists.freebsd.org/pipermail/freebsd-net/2013-July/035999.html>
> > 
> > No, not yet, will have a look. Not sure what you mean by "TCP timestamps
> > are not really used" though. I might be biased by usually only looking at
> > Linux traffic, but I was under that impression that everyone is using
> > TCP timestamps nowadays?
> 
> We had a thread here on netdev:
> <http://thread.gmane.org/gmane.linux.network/275681/>
> 
> It seems, Windows stopped using tcp timestamps at least in windows 8 by
> default.

I see. Well, that seems to be a general problem with SYN cookies, I guess
in that case the encoding Linux uses should be changed. I'll have a closer
look at the changes proposed in that thread tommorrow.
