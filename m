From: Simon Horman <horms@verge.net.au>
Subject: Re: Possible regression in HTB
Date: Thu, 9 Oct 2008 22:18:38 +1100
Message-ID: <20081009111836.GB28667@verge.net.au>
References: <48EB5A92.6010704@trash.net> <20081007220022.GA2664@ami.dom.local> <20081008002153.GL12021@verge.net.au> <48EBFF5E.1090902@trash.net> <20081008065551.GB4174@ff.dom.local> <20081008072203.GJ22396@verge.net.au> <20081008080340.GE4174@ff.dom.local> <20081009005437.GA6342@verge.net.au> <20081009062145.GA4159@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Martin Devera <devik@cdi.cz>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:42216 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756412AbYJILSk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2008 07:18:40 -0400
Content-Disposition: inline
In-Reply-To: <20081009062145.GA4159@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 09, 2008 at 06:21:45AM +0000, Jarek Poplawski wrote:
> On Thu, Oct 09, 2008 at 11:54:40AM +1100, Simon Horman wrote:
> > On Wed, Oct 08, 2008 at 08:03:40AM +0000, Jarek Poplawski wrote:
> ...
> > > OK. But as Patrick mentioned it would be interesting to try a little
> > > below hardware limits: 950, or maybe lower, until HTB starts getting
> > > accuracy.
> > 
> > Hi,
> 
> Hi Simon,
> 
> > 
> > it seems that for my particular setup the magic number is 935Mbit/s.

[snip]

> It's hard to believe so small change can matter so much here!!!
> Great testing!

Thanks, I was rather surprised myself.

> It seems it's safer to use something below such magic number, and
> generally 10% below hardware limit could be the rule.

That kind of rule would certainly solve this case,
not it would be nice for such a rule not to be necessary.

> It also looks like my idea that the first class could get not enough
> packets was wrong. It seems it's rather blocked by other classes when
> HTB thinks it can lend more.
> 
> Anyway, I'm also surprised HTB could be still so exact: congratulations
> Martin!
> 
> Simon, if I don't miss something, I guess you should be OK with these
> last changes in requeuing? The older way did some safety for such
> overestimated configs by hiding the real problem, but there were the
> costs: cpu etc.

I think that as Martin pointed out in another post, there
is really too much hypotheses going on at this point.
I think that it would be nice to try and get to the bottom of this,
but I'm prepared to concede that it isn't a show-stopper.

-- 
Simon Horman
  VA Linux Systems Japan K.K., Sydney, Australia Satellite Office
  H: www.vergenet.net/~horms/             W: www.valinux.co.jp/en

