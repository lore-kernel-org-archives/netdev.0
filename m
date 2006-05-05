From: Horms <horms@verge.net.au>
Subject: Re: [rfc][patch] ipvs: use proper timeout instead of fixed value
Date: Fri, 5 May 2006 12:20:54 +0900
Message-ID: <20060505032052.GY32328@verge.net.au>
References: <20060504201116.GA24394@gospo.rdu.redhat.com> <20060505004754.GA6943@verge.net.au> <20060505025111.GA29142@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, wensong@linux-vs.org, ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:19136 "EHLO koto.vergenet.net")
	by vger.kernel.org with ESMTP id S932464AbWEEDZN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 May 2006 23:25:13 -0400
To: Andy Gospodarek <andy@greyhouse.net>
Content-Disposition: inline
In-Reply-To: <20060505025111.GA29142@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 04, 2006 at 10:51:11PM -0400, Andy Gospodarek wrote:
> On Fri, May 05, 2006 at 09:47:56AM +0900, Horms wrote:
> > On Thu, May 04, 2006 at 04:11:16PM -0400, Andy Gospodarek wrote:
> > > 
> > > Instead of using the default timeout of 3 minutes, this uses the timeout
> > > specific to the protocol used for the connection. The 3 minute timeout
> > > seems somewhat arbitrary (though I know it is used other places in the
> > > ipvs code) and when failing over it would be much nicer to use one of
> > > the configured timeout values.
> > 
> > Hi Andy,
> > 
> > I agree that the current value is somewhat arbitary, 
> > however I'm more in favour of setting it idependantly
> > of other timeouts, perhaps via proc. In any case,
> > won't pp->timeout_table[cp->state] be rather long in
> > the ESTABLISHED case?
> > 
> 
> Horms,
> 
> I agree that there could be a long timeout for ESTABLISHED connections,
> but I've run across a situation where I need exactly that.  When testing
> failover from master to backup I realize that all of my interactive
> sessions get dropped much sooner than the timeout I've configured (mine
> is currently set for much longer than 3 minutes).  If I wanted
> established connections to timeout quickly I would set the timeout to be
> a small value.

Sorry, I missunderstood your patch completely the first time around.
Yes I think this is an excellent idea. Assuming its tested and works
I'm happy to sign off on it and prod DaveM.

-- 
Horms                                           http://www.vergenet.net/~horms/

