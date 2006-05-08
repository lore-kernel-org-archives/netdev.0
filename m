From: Horms <horms@verge.net.au>
Subject: Re: [rfc][patch] ipvs: use proper timeout instead of fixed value
Date: Mon, 8 May 2006 17:56:25 +0900
Message-ID: <20060508085623.GB8450@verge.net.au>
References: <20060504201116.GA24394@gospo.rdu.redhat.com> <20060505004754.GA6943@verge.net.au> <20060505025111.GA29142@gospo.rdu.redhat.com> <20060505032052.GY32328@verge.net.au> <20060505185726.GB24394@gospo.rdu.redhat.com> <20060507043838.GF8374@verge.net.au> <20060508031333.GA25913@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, wensong@linux-vs.org, ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:60879 "EHLO koto.vergenet.net")
	by vger.kernel.org with ESMTP id S1750902AbWEHJDp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 May 2006 05:03:45 -0400
To: Andy Gospodarek <andy@greyhouse.net>
Content-Disposition: inline
In-Reply-To: <20060508031333.GA25913@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, May 07, 2006 at 11:13:33PM -0400, Andy Gospodarek wrote:
> On Sun, May 07, 2006 at 01:38:40PM +0900, Horms wrote:
> > On Fri, May 05, 2006 at 02:57:26PM -0400, Andy Gospodarek wrote:
> > > On Fri, May 05, 2006 at 12:20:54PM +0900, Horms wrote:
> > > > 
> > > > Sorry, I missunderstood your patch completely the first time around.
> > > > Yes I think this is an excellent idea. Assuming its tested and works
> > > > I'm happy to sign off on it and prod DaveM.
> > > 
> > > Horms,
> > > 
> > > I'll get a setup together and post results when I have them.
> > 
> > I was thinking that it would be nice if the timeout could be sent over
> > the wire, though that might bring in some compatibility issues,
> > and thus your approach might be the best idea.
> > 
> > -- 
> > Horms                                           http://www.vergenet.net/~horms/
> 
> 
> Horms,
> 
> At first I too thought about including the timeout in the messages would
> be nice, but it could raise compatibility issues with maybe the only
> advantage being that it would allow quicker timeout of connections --
> something that might be undesirable in such an LVS environment.

Yes, I agree. Wensong raised the issue of having many many connections
on the backup, I personally think thats its unlikely that would be a
problem in practice, though making it tunable might be nice in any case.

-- 
Horms                                           http://www.vergenet.net/~horms/

