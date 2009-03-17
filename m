From: Felix von Leitner <felix-kernel@fefe.de>
Subject: Re: socket api problem: can't bind an ipv6 socket to ::ffff:0.0.0.0
Date: Tue, 17 Mar 2009 19:01:37 +0100
Message-ID: <20090317180136.GB13270@codeblau.de>
References: <20090316233934.GD32111@codeblau.de> <49BF0A5A.2040501@hp.com> <20090317125845.GB9754@codeblau.de> <49BFA9F0.6070702@hp.com> <20090317141432.GA10575@codeblau.de> <49BFBFF4.5060206@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vlad Yasevich <vladislav.yasevich@hp.com>,
	Brian Haley <brian.haley@hp.com>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ioctl.codeblau.de ([80.190.240.67]:39813 "EHLO codeblau.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754141AbZCQSBk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Mar 2009 14:01:40 -0400
Content-Disposition: inline
In-Reply-To: <49BFBFF4.5060206@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Trying to understand why you seem furious, lets try to be pragmatic.

I'm not furious.  I just get angry when people I submit a bug report to
tell me they don't want to fix the bug.

Some people think that if I submit a bug to them, they are doing me a
service if they fix the bug.  In fact it's the opposite of that.  If I
submit a bug, I am doing them a service, because I am telling them in
what way their software fails to meet the requirements of the users.

> Most users of your great program wont have a fix for this until next year.

You underestimate my users.  The few ones that run into this kind of
problem are not above patching their kernels to make it work.

But I am not willing to provide a kernel patch and do the customer
support for that.

> I am afraid you have no choice but change your program, or loose users.

No I will not.  My program works.  Just not on Linux.
If my users see that "the Linux people" don't consider running high
profile high throughput messing systems important enough to remove one
if clause of dubious merit, then they go switch to Solaris or FreeBSD
instead.  And then Solaris and FreeBSD get the PR benefit.

> Still I dont get your point. Having TCP V6 sockets is much more expensive
> at kernel level (same for UDP), and bittorrent is known to stress network a bit, so
> having application use an IPV4 socket where it can is a win for your
> program getting more users, and computers spend less power.

There are two things to say to that:

  1. IPv6 is the future.  If I implement IPv4 code because the IPv6 code
  is slower, there will never be an incentive for the kernel people to
  tune the IPv6 code, and it will continue to suck.

  2. IPv4 users won't ever switch to IPv6 if they hear it's so slow that
  people like me had to provide a legacy code path for performance
  reasons.  That is exactly the wrong message to send.

  3. In my benchmarks the performance difference was negligible.  It was
  in the area of 1-2%, i.e. within the margin of error.

> Gasp, OSX having this "::ffff:0.0.0.0" right is probably the reason why more computers
>  run OSX than linux. Sometime dont implement RFC too literally :)

Your target audience is not the RFCs, it's the people.
And the people just told you that you implemented this part of the code
wrong.

Please listen to your users and don't berate them.

Even if we assume that the RFCs can be read so that the current
implementation is technically not illegal, note that the other operating
systems interpreted it differently.  So you miss the main goal of the
RFCs, providing a fertile ground for interoperability.

Just forget all I said.  Just look at the facts.

The RFCs are unclear.
All the other major IPv6 stacks do it the other way.
Maybe they are right?

Felix
