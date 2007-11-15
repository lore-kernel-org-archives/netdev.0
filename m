From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [PATCH 2/7] CAN: Add PF_CAN core module
Date: Thu, 15 Nov 2007 16:11:37 +0100
Message-ID: <20071115151137.GB22825@uranus.ravnborg.org>
References: <473BF7FD.7010403@hartkopp.net> <1195113860.27113.34.camel@localhost> <ygfmytfbubd.fsf@janus.isnogud.escape.de> <20071115.040530.205831740.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: urs.thuermann@gmx.de, joe@perches.com, oliver@hartkopp.net,
	shemminger@linux-foundation.org, netdev@vger.kernel.org,
	kaber@trash.net, oliver.hartkopp@volkswagen.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pasmtpa.tele.dk ([80.160.77.114]:37735 "EHLO pasmtpA.tele.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753283AbXKOPJ6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2007 10:09:58 -0500
Content-Disposition: inline
In-Reply-To: <20071115.040530.205831740.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 15, 2007 at 04:05:30AM -0800, David Miller wrote:
> From: Urs Thuermann <urs.thuermann@gmx.de>
> Date: 15 Nov 2007 12:51:34 +0100
> 
> > I prefer our code because it is shorter (fits into one line) and can
> > be used anywhere where an expression is allowed compared to only where
> > a statement is allowed.  Actually, I first had
> > 
> >         #define DBG( ... )   ((debug & 1) && printk( ... ))
> > 
> > and so on, but that didn't work with can_debug_{cframe,sbk} since they
> > return void.
> > 
> > Admitted, the benefit of expr vs. statement is really negligible and
> > since this issue has come up several times I will change these macros
> > using do-while.
> 
> I really frown upon these local debugging macros people tend to want
> to submit with their changes.
> 
> It really craps up the tree, even though it might be useful to you.
> 
> So please remove this stuff or replace the debugging statements
> with some generic kernel debugging facility, there are several.

It would be usefull if someone could make a short intro to the preferred
ones and we could stuff it in Documentation/*

Had same comment but had nowhere to point the can guys at.

	Sam
