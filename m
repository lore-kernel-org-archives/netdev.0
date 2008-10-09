From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Possible regression in HTB
Date: Thu, 9 Oct 2008 12:36:12 +0000
Message-ID: <20081009123612.GB6588@ff.dom.local>
References: <48EB5A92.6010704@trash.net> <20081007220022.GA2664@ami.dom.local> <20081008002153.GL12021@verge.net.au> <48EBFF5E.1090902@trash.net> <20081008065551.GB4174@ff.dom.local> <20081008072203.GJ22396@verge.net.au> <20081008080340.GE4174@ff.dom.local> <20081009005437.GA6342@verge.net.au> <20081009062145.GA4159@ff.dom.local> <20081009111836.GB28667@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Martin Devera <devik@cdi.cz>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.189]:9525 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754681AbYJIMgU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2008 08:36:20 -0400
Received: by fk-out-0910.google.com with SMTP id 18so3744434fkq.5
        for <netdev@vger.kernel.org>; Thu, 09 Oct 2008 05:36:18 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20081009111836.GB28667@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 09, 2008 at 10:18:38PM +1100, Simon Horman wrote:
> On Thu, Oct 09, 2008 at 06:21:45AM +0000, Jarek Poplawski wrote:
...
> > It seems it's safer to use something below such magic number, and
> > generally 10% below hardware limit could be the rule.
> 
> That kind of rule would certainly solve this case,
> not it would be nice for such a rule not to be necessary.

As a matter of fact I think most of admins get used to this, especially
with various dsls etc. As you can see, your 1Gbit isn't real rate here,
so what you propose is ignoring parameters and doing autodetection,
which is possible but, probably erroneus as well.

> > Simon, if I don't miss something, I guess you should be OK with these
> > last changes in requeuing? The older way did some safety for such
> > overestimated configs by hiding the real problem, but there were the
> > costs: cpu etc.
> 
> I think that as Martin pointed out in another post, there
> is really too much hypotheses going on at this point.
> I think that it would be nice to try and get to the bottom of this,
> but I'm prepared to concede that it isn't a show-stopper.

Actually, I really doubt it's any stopper at all. It's a low level
tool, not intended for common use, which really needs some tweaking.
(Some people still prefer CBQ for more control...)

Thanks,
Jarek P.
