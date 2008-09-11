From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] RDS: Add AF and PF defines for RDS sockets
Date: Thu, 11 Sep 2008 14:54:41 -0700 (PDT)
Message-ID: <20080911.145441.258824332.davem@davemloft.net>
References: <1219907200.7107.228.camel@pmac.infradead.org>
	<20080828.002457.26700892.davem@davemloft.net>
	<c0a09e5c0809111144v7f7db03es963aa222147dc3a3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dwmw2@infradead.org, marcel@holtmann.org, netdev@vger.kernel.org
To: andy.grover@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37957
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753439AbYIKVys (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 17:54:48 -0400
In-Reply-To: <c0a09e5c0809111144v7f7db03es963aa222147dc3a3@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Andrew Grover" <andy.grover@gmail.com>
Date: Thu, 11 Sep 2008 11:44:39 -0700

> (reviving an old thread, new comments at bottom)
> 
> On Thu, Aug 28, 2008 at 12:24 AM, David Miller <davem@davemloft.net> wrote:
> > From: David Woodhouse <dwmw2@infradead.org>
> > Date: Thu, 28 Aug 2008 08:06:40 +0100
> >
> >> On Mon, 2008-08-25 at 21:29 -0700, David Miller wrote:
> >> > From: Marcel Holtmann <marcel@holtmann.org>
> >> > Date: Tue, 26 Aug 2008 06:16:28 +0200
> >> >
> >> > > and where is the protocol? Adding new constants without posting the
> >> > > implementation normally doesn't fly anymore.
> >> >
> >> > That's correct :)
> >>
> >> That's kind of unfortunate, and leads to the problems we have with
> >> compatibility for AF_ISDN, where userspace built for the _older_
> >> versions has a different value.
> >>
> >> Is there really any harm in reserving it up-front?
> >
> > If you're commiting a userspace to a kernel component
> > that hasn't been blessed upstream yet, you're already
> > up the creek without a paddle.
> 
> The RDS protocol is already in production use by Oracle, and has been
> in the OFED distribution for a long time. It's under active
> development, and we'll be submitting it soon for mainline.

So?!??!  Upstream doesn't give a crap about what someone is happening
internally.  It doesn't matter, it's irrelevant.

> We just want a number now so userspace can start doing things
> correctly right away.

N-O spells "no".
