From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH v2] net-tcp: TCP/IP stack bypass for loopback
 connections
Date: Wed, 15 Aug 2012 12:17:11 -0400
Message-ID: <20120815121711.f5d6353c.billfink@mindspring.com>
References: <20120814023155.ffe9c01d.billfink@mindspring.com>
	<CAEkNxbFgr1Qws_Fp3igDhir-81R-XWr52inmuXb1MNS9NigU0Q@mail.gmail.com>
	<20120815012428.c747fa9d.billfink@mindspring.com>
	<20120814.223907.1954070712467723629.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brutus@google.com, edumazet@google.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-curtail.atl.sa.earthlink.net ([209.86.89.64]:56461 "EHLO
	elasmtp-curtail.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755276Ab2HOQRQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Aug 2012 12:17:16 -0400
In-Reply-To: <20120814.223907.1954070712467723629.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 14 Aug 2012, David Miller wrote:

> From: Bill Fink <billfink@mindspring.com>
> Date: Wed, 15 Aug 2012 01:24:28 -0400
> 
> > I see no reason to make it obtuse rather than something more
> > descriptive of its function (as opposed to how it's implemented).
> 
> I want to live in a world where things are allowed to have some
> character, and some slightly amusing names.  And that's why we'll
> call it TCP friends, thank you very much.

That's too bad.  You seem to disdain user input in favor
of personal amusement.  A very poor argument in my opinion.

> > I do have some concern that since the loopback path through the
> > TCP stack won't be heavily exercised anymore, it may be more likely
> > for bugs or performance degradations to creep into that code.
> 
> Are you kidding me?  Most people do not use loopback TCP, they use
> TCP to a real external entity.  TCP friends only kicks in for
> loopback connections.
> 
> So, like all of your other concerns, this one is meritless.

You like kicking dead horses I guess.  I already agreed that
having the option enabled by default was fine after Bruce's
helpful info in response to my concerns.

And using the real TCP loopback can be very useful in analyzing
the functionality and performance of systems and applications
as an initial baseline before testing across real networks.
It can help identify system bottlenecks and scope out the outer
boundaries of what's possible to achieve.

Just because most people don't use loopback TCP doesn't mean
it doesn't have valid and useful purposes for some.  And it's
interesting that your argument here that "most people do not
use loopback TCP" is in opposition to your previous argument
for enabling the option by default that "it benefits basically
everyone".

But this is further kicking of a dead horse.  I've agreed
that having the option enabled by default is fine and I
will continue to disagree about the option name, but that
is your call of course.

					-Bill
