From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference at
 000000000000002c
Date: Thu, 2 Feb 2012 16:42:28 -0800
Message-ID: <20120203004228.GA23429@kroah.com>
References: <20120201.162157.880976652659067010.davem@davemloft.net>
 <4F2A87B0.6070900@profihost.ag>
 <1328195055.2279.61.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <20120202.143957.2251106530056768980.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	s.priebe@profihost.ag, jwboyer@gmail.com, hch@infradead.org,
	netdev@vger.kernel.org, david@fromorbit.com,
	stable@vger.kernel.org, gregkh@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:38549 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754157Ab2BCAo6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2012 19:44:58 -0500
Received: from compute2.internal (compute2.nyi.mail.srv.osa [10.202.2.42])
	by gateway1.nyi.mail.srv.osa (Postfix) with ESMTP id 3D19621B3D
	for <netdev@vger.kernel.org>; Thu,  2 Feb 2012 19:44:58 -0500 (EST)
Content-Disposition: inline
In-Reply-To: <20120202.143957.2251106530056768980.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 02, 2012 at 02:39:57PM -0500, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 02 Feb 2012 16:04:15 +0100
> 
> > David, what do you think ?
> 
> I frankly don't care at this point.
> 
> The only reasonable thing is if someone can successfully do the
> backport, but if that's not possible there really isn't anything
> reasonable we can do, all the other options have fatal negative
> consequences which make them completely untenable.

I agree.  I'm pretty sure the distros basing their releases on 3.0 are
aware of this issue, so perhaps someone could dig through those tree and
see how they resolved this issue, if at all.

thanks,

greg k-h
