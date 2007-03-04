From: David Miller <davem@davemloft.net>
Subject: Re: Extensible hashing and RCU
Date: Sun, 04 Mar 2007 12:36:58 -0800 (PST)
Message-ID: <20070304.123658.104032879.davem@davemloft.net>
References: <f2b55d220703021245m5cd5d9eet5e5a9d0d8ffcea41@mail.gmail.com>
	<20070303104620.GD22557@2ka.mipt.ru>
	<f2b55d220703040202y7d6e5c72q8b5c8fd3d11fd06a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, dada1@cosmosbay.com, akepner@sgi.com,
	linux@horizon.com, netdev@vger.kernel.org
To: medwards.linux@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46416
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752474AbXCDUg7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Mar 2007 15:36:59 -0500
In-Reply-To: <f2b55d220703040202y7d6e5c72q8b5c8fd3d11fd06a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael K. Edwards" <medwards.linux@gmail.com>
Date: Sun, 4 Mar 2007 02:02:36 -0800

> On 3/3/07, Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> > Btw, you could try to implement something you have written above to show
> > its merits, so that it would not be an empty words :)
> 
> Before I implement, I design.  Before I design, I analyze.  Before I
> analyze, I prototype.  Before I prototype, I gather requirements.

How the heck do you ever get to writing ANYTHING if you work that way?

I certainly would never have written one single line of Linux kernel
code if I had to go through that kind of sequence to actually get to
writing code.

And that's definitely not the "Linux way".  You code up ideas as soon
as you come up with one that has a chance of working, and you see what
happens.  Sure, you'll throw a lot away, but at least you will "know"
instead of "think".

You have to try things, "DO" stuff, not just sit around and theorize
and design things and shoot down ideas on every negative minute detail
you can come up with before you type any code in.  That mode of
development doesn't inspire people and get a lot of code written.

I definitely do not think others should use this
design/prototype/analyze/blah/balh way of developing as an example,
instead I think folks should use people like Ingo Molnar as an example
of a good Linux developer.  People like Ingo rewrite the scheduler one
night because of a tiny cool idea, and even if only 1 out of 10 hacks
like that turn out to be useful, his work is invaluable and since he's
actually trying to do things and writing lots of code this inspires
other people.
