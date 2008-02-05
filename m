From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Add IPv6 support to TCP SYN cookies
Date: Tue, 5 Feb 2008 17:39:12 +0100
Message-ID: <20080205163912.GB23145@one.firstfloor.org>
References: <47a79d64.16538c0a.5b6a.ffffb0fe@mx.google.com> <20080205155558.GA23145@one.firstfloor.org> <20080205154213.059ac6e8@core>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	Glenn Griffin <ggriffin.kernel@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:43342 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752495AbYBEQET (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 11:04:19 -0500
Content-Disposition: inline
In-Reply-To: <20080205154213.059ac6e8@core>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 05, 2008 at 03:42:13PM +0000, Alan Cox wrote:
> > Syncookies are discouraged these days. They disable too many 
> > valuable TCP features (window scaling, SACK) and even without them 
> > the kernel is usually strong enough to defend against syn floods
> > and systems have much more memory than they used to be.
> 
> Somewhat untrue. Network speeds have risen dramatically, the number of

With strong I meant Linux has much better algorithms to handle the standard
syn queue (syncookies was originally added when it had only dumb head drop) 
and there are minisocks which also require significantly less overhead
to manage than full sockets (less memory etc.) 

When I wrote syncookies originally that all was not true.

> appliances running Linux that are not PC class means memory has fallen
> not risen and CPU has been pretty level.
> 
> > So I don't think it makes much sense to add more code to it, sorry.
> 
> I think it makes a lot of sense 

I have my doubts. It would be probably better to recheck everything
and then remove syncookies.

Also your sub PC class appliances rarely run LISTEN servers anyways
that are open to the world.

-Andi
