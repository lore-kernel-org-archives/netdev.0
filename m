From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Devel] Re: Network virtualization/isolation
Date: Fri, 8 Dec 2006 22:13:48 -0800
Message-ID: <20061208221348.b263e3c2.akpm@osdl.org>
References: <453F8800.9070603@fr.ibm.com>
	<1165239894.3664.61.camel@localhost>
	<m1k617u10x.fsf@ebiederm.dsl.xmission.com>
	<200612041900.42768.dim@openvz.org>
	<m1odqj8uyt.fsf@ebiederm.dsl.xmission.com>
	<4576AF68.2070604@sw.ru>
	<20061206183036.GA16927@MAIL.13thfloor.at>
	<m164cm2m9u.fsf@ebiederm.dsl.xmission.com>
	<20061209035002.GA11747@MAIL.13thfloor.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Kirill Korotaev <dev@sw.ru>,
	Linux Containers <containers@lists.osdl.org>,
	Dmitry Mishin <dim@openvz.org>, netdev@vger.kernel.org,
	hadi@cyberus.ca, Stephen Hemminger <shemminger@osdl.org>,
	Linus Torvalds <torvalds@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:49406 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759217AbWLIGTM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Dec 2006 01:19:12 -0500
To: Herbert Poetzl <herbert@13thfloor.at>
In-Reply-To: <20061209035002.GA11747@MAIL.13thfloor.at>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 9 Dec 2006 04:50:02 +0100
Herbert Poetzl <herbert@13thfloor.at> wrote:

> On Fri, Dec 08, 2006 at 12:57:49PM -0700, Eric W. Biederman wrote:
> > Herbert Poetzl <herbert@13thfloor.at> writes:
> > 
> > >> But, ok, it is not the real point to argue so much imho 
> > >> and waste our time instead of doing things.
> 
> > > well, IMHO better talk (and think) first, then implement
> > > something ... not the other way round, and then start
> > > fixing up the mess ...
> > 
> > Well we need a bit of both.
> 
> hmm, are 'we' in a hurry here?
> 
> until recently, 'Linux' (mainline) didn't even want
> to hear about OS Level virtualization, now there
> is a rush to quickly get 'something' in, not knowing
> or caring if it is usable at all?

It's actually happening quite gradually and carefully.

> I think there are a lot of 'potential users' for
> this kind of virtualization, and so 'we' can test
> almost all aspects outside of mainline, and once
> we know the stuff works as expected, then we can
> integrate it ...
> 
> the UTS namespace was something 'we all' had already
> implemented in this (or a very similar) way, and in
> one or two interations, it should actually work as 
> expected. nevertheless, it was one of the simplest
> spaces ...
> 
> we do not yet know the details for the IPC namespace,
> as IPC is not that easy to check as UTS, and 'we'
> haven't gotten real world feedback on that yet ...

We are very dependent upon all stakeholders including yourself to review,
test and comment upon this infrastructure as it is proposed and merged.
If something is proposed which will not suit your requirements then it
is important that we hear about it, in detail, at the earliest possible time.

Thanks.
