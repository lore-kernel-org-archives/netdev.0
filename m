From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [PATCH 03/27] drivers/net: fix sparse warning: returning void-valued expression
Date: Sat, 27 Dec 2008 20:20:12 +0100
Message-ID: <20081227192012.GB10592@uranus.ravnborg.org>
References: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net> <20081222191517.11807.20718.stgit@vmbox.hanneseder.net> <20081225.161740.10052019.davem@davemloft.net> <20081226115921.bb094c58.rdunlap@xenotime.net> <49567dd3.0b38560a.3c6c.0511@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Randy Dunlap <rdunlap@xenotime.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Hannes Eder <hannes@hanneseder.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfepa.post.tele.dk ([195.41.46.235]:34231 "EHLO
	pfepa.post.tele.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753604AbYL0TSl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Dec 2008 14:18:41 -0500
Content-Disposition: inline
In-Reply-To: <49567dd3.0b38560a.3c6c.0511@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 27, 2008 at 08:11:11PM +0100, Hannes Eder wrote:
> On 12/26/08, Randy Dunlap <rdunlap@xenotime.net> wrote:
> > On Thu, 25 Dec 2008 16:17:40 -0800 (PST)
> >  
> > David Miller <davem@davemloft.net> wrote:
> >  
> >  
> > > From: Hannes Eder <hannes@hanneseder.net>
> >  > Date: Mon, 22 Dec 2008 20:15:17 +0100
> >  >
> >  > > Fix this sparse warning:
> >  > >
> >  > >   drivers/net/niu.c:8850:2: warning: returning void-valued expression
> >  > >
> >  > > Signed-off-by: Hannes Eder <hannes@hanneseder.net>
> >  >
> >  > Can we just fix sparse not to generate this warning?  It's
> >  > marginal, at best.  C++ even explicitly defines this as valid
> >  > and last time I brought this up Linus even agreed.
> >  
> >  
> > Ack, I discussed it with him also and he thought that
> >  they were just fine as they were...
> >  
> > 
> >  > The types match, the function returns void and it is returning a void,
> >  > what is the problem?
> 
> In fact there is no need to _fix_ sparse, as there is a command line option
> -Wreturn-void / -Wno-return-void, so we could change the Makefile, see diff
> below.

It is default off but out use of "-Wall" turn it on.
So your patch is the right approach.

Can you please re-send it with a proper changelog and signed-off.

	Sam
