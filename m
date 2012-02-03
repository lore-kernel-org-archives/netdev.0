From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference at
 000000000000002c
Date: Fri, 3 Feb 2012 07:52:22 -0800
Message-ID: <20120203155222.GA20638@kroah.com>
References: <20120201.162157.880976652659067010.davem@davemloft.net>
 <4F2A87B0.6070900@profihost.ag>
 <1328195055.2279.61.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <20120202.143957.2251106530056768980.davem@davemloft.net>
 <20120203004228.GA23429@kroah.com>
 <4F2B8348.3090305@profihost.ag>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	jwboyer@gmail.com, hch@infradead.org, netdev@vger.kernel.org,
	david@fromorbit.com, stable@vger.kernel.org, gregkh@suse.de
To: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:47858 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754072Ab2BCPyn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2012 10:54:43 -0500
Received: from compute4.internal (compute4.nyi.mail.srv.osa [10.202.2.44])
	by gateway1.nyi.mail.srv.osa (Postfix) with ESMTP id 0C03620C15
	for <netdev@vger.kernel.org>; Fri,  3 Feb 2012 10:54:43 -0500 (EST)
Content-Disposition: inline
In-Reply-To: <4F2B8348.3090305@profihost.ag>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 03, 2012 at 07:48:40AM +0100, Stefan Priebe - Profihost AG wrote:
> Am 03.02.2012 01:42, schrieb Greg KH:
> > On Thu, Feb 02, 2012 at 02:39:57PM -0500, David Miller wrote:
> >> From: Eric Dumazet <eric.dumazet@gmail.com>
> >> Date: Thu, 02 Feb 2012 16:04:15 +0100
> >>
> >>> David, what do you think ?
> >>
> >> I frankly don't care at this point.
> >>
> >> The only reasonable thing is if someone can successfully do the
> >> backport, but if that's not possible there really isn't anything
> >> reasonable we can do, all the other options have fatal negative
> >> consequences which make them completely untenable.
> > 
> > I agree.  I'm pretty sure the distros basing their releases on 3.0 are
> > aware of this issue, so perhaps someone could dig through those tree and
> > see how they resolved this issue, if at all.
> > 
> I haven't found any distris which has backported something regarding
> this issue.
> 
> Also it seems that there's only Ubuntu using 3.0. Debian and others have
> already moved to 3.1 / 3.2. Anything i miss?

SUSE's SLES11 SP2 is based on 3.0, as is a zillion different Android
devices shipping and about to ship, based on the "IceCream Sandwich"
release.

So there will end up being more 3.0 based Linux kernel devices then
probably any other previous kernel version floating around in the
wild...

> I've made my own backport of the patch and removed at least 1-2
> dependencies. Anybody interested?

Yes, that would be great to have.

greg k-h
