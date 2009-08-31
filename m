From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] Re: iproute2 / tbf with large burst seems broken again
Date: Mon, 31 Aug 2009 08:49:26 +0000
Message-ID: <20090831084926.GE5005@ff.dom.local>
References: <20090826215956.GA5148@ami.dom.local> <20090831053026.GA5005@ff.dom.local> <20090830.223239.185830289.davem@davemloft.net> <200908311118.43024.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f217.google.com ([209.85.220.217]:47805 "EHLO
	mail-fx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751010AbZHaIta (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2009 04:49:30 -0400
Received: by fxm17 with SMTP id 17so2620929fxm.37
        for <netdev@vger.kernel.org>; Mon, 31 Aug 2009 01:49:31 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200908311118.43024.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 31, 2009 at 11:18:42AM +0300, Denys Fedoryschenko wrote:
> On Monday 31 August 2009 08:32:39 David Miller wrote:
> > From: Jarek Poplawski <jarkao2@gmail.com>
> > Date: Mon, 31 Aug 2009 05:30:27 +0000
> >
> > > Actually, I think now, after 2.6.31, this patch might be a bit too
> > > late. If people hit this problem they probably should've fixed it
> > > until -next already, so let's forget about this patch until there are
> > > more such reports.
> >
> > Ok.
> >
> > > Btw, I guess, Denys could submit some warnings into iproute's code
> > > and/or documentation, as he proposed earlier.
> >
> > Yeah sounds like a good idea.
> 
> 2.6.31-rc8 i got dmesg flooded. First message appearing even without patch, i 
> will make sure now what is a reason of that (i have HTB classes on ifb0, and 
> TBF on pppX).
> 
> [  155.199923] Attempt to kill tasklet from interrupt
> [  158.425096] Attempt to kill tasklet from interrupt
> [  158.425176] Attempt to kill tasklet from interrupt
> [  162.549083] Attempt to kill tasklet from interrupt
> [  162.549159] Attempt to kill tasklet from interrupt
> [  162.601892] Attempt to kill tasklet from interrupt
> [  162.601968] Attempt to kill tasklet from interrupt
> [  183.719070] Attempt to kill tasklet from interrupt
> [  183.719146] Attempt to kill tasklet from interrupt
> [  192.147105] Attempt to kill tasklet from interrupt
> [  192.147181] Attempt to kill tasklet from interrupt
> [  192.604718] tbf: tokens overflow; fix limits.
> [  193.085459] tbf: tokens overflow; fix limits.
> [  193.102169] tbf: tokens overflow; fix limits.
> [  194.100395] tbf: tokens overflow; fix limits.
> [  196.010286] tbf: tokens overflow; fix limits.
> [  196.014330] tbf: tokens overflow; fix limits.
> [  196.100723] tbf: tokens overflow; fix limits.
> [  196.104619] tbf: tokens overflow; fix limits.
> [  196.998374] tbf: tokens overflow; fix limits.
> [  197.854766] tbf: tokens overflow; fix limits.
> [  198.676258] tbf: tokens overflow; fix limits.
> [  198.676564] tbf: tokens overflow; fix limits.
> [  198.984620] tbf: tokens overflow; fix limits.
> [  199.599671] tbf: tokens overflow; fix limits.
> [  200.101338] tbf: tokens overflow; fix limits.                                                                                                                                                          

I guess it's with a very large (wrt. rate) tbf buffer setting?
Btw, of course testing it would be appreciated, but as I wrote
earlier we can probably wait with this patch for more reports.

Jarek P.
