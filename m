From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [Devel] Re: Network virtualization/isolation
Date: Sat, 09 Dec 2006 01:07:22 -0700
Message-ID: <m1k611ze4l.fsf@ebiederm.dsl.xmission.com>
References: <453F8800.9070603@fr.ibm.com> <1165239894.3664.61.camel@localhost>
	<m1k617u10x.fsf@ebiederm.dsl.xmission.com>
	<200612041900.42768.dim@openvz.org>
	<m1odqj8uyt.fsf@ebiederm.dsl.xmission.com> <4576AF68.2070604@sw.ru>
	<20061206183036.GA16927@MAIL.13thfloor.at>
	<m164cm2m9u.fsf@ebiederm.dsl.xmission.com>
	<20061209035002.GA11747@MAIL.13thfloor.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kirill Korotaev <dev@sw.ru>,
	Linux Containers <containers@lists.osdl.org>,
	Dmitry Mishin <dim@openvz.org>, netdev@vger.kernel.org,
	hadi@cyberus.ca, Stephen Hemminger <shemminger@osdl.org>,
	Andrew Morton <akpm@osdl.org>,
	Linus Torvalds <torvalds@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:35754 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934223AbWLIIIq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Dec 2006 03:08:46 -0500
To: Herbert Poetzl <herbert@13thfloor.at>
In-Reply-To: <20061209035002.GA11747@MAIL.13thfloor.at> (Herbert Poetzl's
	message of "Sat, 9 Dec 2006 04:50:02 +0100")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Poetzl <herbert@13thfloor.at> writes:

> On Fri, Dec 08, 2006 at 12:57:49PM -0700, Eric W. Biederman wrote:
>> Herbert Poetzl <herbert@13thfloor.at> writes:
>> 
>> >> But, ok, it is not the real point to argue so much imho 
>> >> and waste our time instead of doing things.
>
>> > well, IMHO better talk (and think) first, then implement
>> > something ... not the other way round, and then start
>> > fixing up the mess ...
>> 
>> Well we need a bit of both.
>
> hmm, are 'we' in a hurry here?

We need to talk about code, and particular patches not just talk.

There are two sides to what we are building.
- The user interface, and semantics.
- The kernel implementation.

For the user interface getting it as close to perfect as we can
the first time is extremely important.  Because we won't be able
to change it.

For the kernel implementation we don't have to be perfect we have
to have something that is good enough.  We can change the
implementation every release if we find better ways of implementing
our user space semantics. 

> until recently, 'Linux' (mainline) didn't even want
> to hear about OS Level virtualization, now there
> is a rush to quickly get 'something' in, not knowing
> or caring if it is usable at all?
>
> I think there are a lot of 'potential users' for
> this kind of virtualization, and so 'we' can test
> almost all aspects outside of mainline, and once
> we know the stuff works as expected, then we can
> integrate it ...

We should do this as part of the linux kernel community.  There
is no outside of mainline development.  We need to get feedback from
other developers whose code we may effect.  This is particularly true
of the kernel networking stack.

> that's something I do not really agree with, stuff
> integrated into the kernel should be well designed
> and it should be tested ...

Yes but you can break a problem into reasonable chunks and
solve each of those pieces individually. 

Eric




