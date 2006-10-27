From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: don't allow unfair congestion control to be built
 without warning
Date: Fri, 27 Oct 2006 15:12:38 -0700 (PDT)
Message-ID: <20061027.151238.59655130.davem@davemloft.net>
References: <20061027142402.07a47f3f@freekitty>
	<20061027.143701.85411558.davem@davemloft.net>
	<20061027145913.04dc0e5f@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hagen@jauu.net, jheffner@psc.edu, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:38325
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750764AbWJ0WMh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Oct 2006 18:12:37 -0400
To: shemminger@osdl.org
In-Reply-To: <20061027145913.04dc0e5f@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Fri, 27 Oct 2006 14:59:13 -0700

> On Fri, 27 Oct 2006 14:37:01 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
> > From: Stephen Hemminger <shemminger@osdl.org>
> > Date: Fri, 27 Oct 2006 14:24:02 -0700
> > 
> > > Only some (very few) have any bad consequences. So the typical
> > > distribution should be able to switch with most available for everyone,
> > > and only a few needing special privileges.
> > 
> > I would strongly disagree as we've had several OOPS'er class bugs in
> > the less frequently used algorithms.
> > 
> 
> Then tag those as restricted.  Why should we keep app's away from
> the simple ones.

You can't predict bugs, but what you can do is know that the lesser
used algorithms are by definition less tested and therefore more
likely to have bugs.  Everything except the default and Reno are
lesser used.

Safe by default, there is no other choice.  You fail to respond to
THAT part of my email.  That's the important point.  Let me
reiterate:

> It's bad enough that people are all over us for the default algorithm
> we have choosen, so it'd be extremely irresponsible and even worse if
> we allowed users to select any of the other "research" algorithms for
> their TCP connections by default just because those modules happened
> to be configured into the kernel.
>
> This userspace convenience argument holds zero water.
>
> Provide a way for the administrator to control the situation fully,
> and choose a sane default which errs on the side of caution for the
> sake of internet stability.

Please reread this and consider why it's important.
