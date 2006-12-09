From: Dmitry Mishin <dim@openvz.org>
Subject: Re: [Devel] Re: Network virtualization/isolation
Date: Sun, 10 Dec 2006 00:18:08 +0300
Message-ID: <200612100018.08855.dim@openvz.org>
References: <453F8800.9070603@fr.ibm.com> <20061208221348.b263e3c2.akpm@osdl.org> <20061209063517.GG11747@MAIL.13thfloor.at>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Kirill Korotaev <dev@sw.ru>,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, hadi@cyberus.ca,
	Stephen Hemminger <shemminger@osdl.org>,
	Linus Torvalds <torvalds@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:16253 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756986AbWLIVSo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Dec 2006 16:18:44 -0500
To: Herbert Poetzl <herbert@13thfloor.at>
In-Reply-To: <20061209063517.GG11747@MAIL.13thfloor.at>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 09 December 2006 09:35, Herbert Poetzl wrote:
> On Fri, Dec 08, 2006 at 10:13:48PM -0800, Andrew Morton wrote:
> > On Sat, 9 Dec 2006 04:50:02 +0100
> > Herbert Poetzl <herbert@13thfloor.at> wrote:
> > 
> > > On Fri, Dec 08, 2006 at 12:57:49PM -0700, Eric W. Biederman wrote:
> > > > Herbert Poetzl <herbert@13thfloor.at> writes:
> > > > 
> > > > >> But, ok, it is not the real point to argue so much imho 
> > > > >> and waste our time instead of doing things.
> > > 
> > > > > well, IMHO better talk (and think) first, then implement
> > > > > something ... not the other way round, and then start
> > > > > fixing up the mess ...
> > > > 
> > > > Well we need a bit of both.
> > > 
> > > hmm, are 'we' in a hurry here?
> > > 
> > > until recently, 'Linux' (mainline) didn't even want
> > > to hear about OS Level virtualization, now there
> > > is a rush to quickly get 'something' in, not knowing
> > > or caring if it is usable at all?
> > 
> > It's actually happening quite gradually and carefully.
> 
> hmm, I must have missed a testing phase for the
> IPC namespace then, not that I think it is broken
> (well, maybe it is, we do not know yet)
Herbert,

you know that this code is used in our product. And in its turn, our
product is tested internally and by a community. We have no reports about
bugs in this code. If you have to say more than just "something to say",
please, say it.

> 
> > > I think there are a lot of 'potential users' for
> > > this kind of virtualization, and so 'we' can test
> > > almost all aspects outside of mainline, and once
> > > we know the stuff works as expected, then we can
> > > integrate it ...
> > > 
> > > the UTS namespace was something 'we all' had already
> > > implemented in this (or a very similar) way, and in
> > > one or two interations, it should actually work as 
> > > expected. nevertheless, it was one of the simplest
> > > spaces ...
> > > 
> > > we do not yet know the details for the IPC namespace,
> > > as IPC is not that easy to check as UTS, and 'we'
> > > haven't gotten real world feedback on that yet ...
> > 
> > We are very dependent upon all stakeholders including yourself 
> > to review, test and comment upon this infrastructure as it is 
> > proposed and merged. If something is proposed which will not 
> > suit your requirements then it is important that we hear about 
> > it, in detail, at the earliest possible time.
> 
> okay, good to hear that I'm still considered a stakeholder 
> 
> will try to focus the feedback and cc as many folks
> as possible, as it seems that some feedback is lost
> on the way upstream ...
> 
> best,
> Herbert
> 
> > Thanks.
> 

-- 
Thanks,
Dmitry.
