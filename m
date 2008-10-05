From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] net: deadlock during net device unregistration
Date: Sun, 5 Oct 2008 09:12:38 +0200
Message-ID: <20081005071238.GA2752@ami.dom.local>
References: <E1KmLCH-0003E2-Ch@gondolin.me.apana.org.au> <20081005065509.GA2538@ami.dom.local> <20081005065648.GA13113@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benjamin Thery <benjamin.thery@bull.net>, davem@davemloft.net,
	netdev@vger.kernel.org, dlezcano@fr.ibm.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:49783 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752529AbYJEHMh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Oct 2008 03:12:37 -0400
Received: by ug-out-1314.google.com with SMTP id k3so1473918ugf.37
        for <netdev@vger.kernel.org>; Sun, 05 Oct 2008 00:12:35 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20081005065648.GA13113@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 05, 2008 at 02:56:48PM +0800, Herbert Xu wrote:
> On Sun, Oct 05, 2008 at 08:55:10AM +0200, Jarek Poplawski wrote:
> >
> > > -	/* Not safe to do outside the semaphore.  We must not return
> > > -	 * until all unregister events invoked by the local processor
> > > -	 * have been completed (either by this todo run, or one on
> > > -	 * another cpu).
> > > -	 */
> > 
> > I think, it's about not to let others run this for devices unregistered
> > within later rtnl_locks before completing previous tasks. So, it would
> > be nice to have some comment why it's not necessary anymore.
> 
> Where did you get that idea?

Just reading this code (plus the comment). Why would anybody bother 
with something so complex like this if something like your idea is
rather straightforward? But, needed or not, my point is it would be
nice to comment that this patch changes this behavior btw.

Jarek P.
